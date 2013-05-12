require 'tcp_timeout'

require_relative './session'

module Rexpro
  class Client
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 8184

    attr_reader :host, :port, :socket

    def initialize(opts = {})
      @host = opts.delete(:host) || DEFAULT_HOST
      @port = opts.delete(:port) || DEFAULT_PORT

      @request_opts = {}
      [:channel, :graph_name, :graph_obj_name].each do |key|
        value = opts.delete(key)
        @request_opts[key] = value if value
      end

      @socket_opts = opts
      reconnect
    end

    def reconnect
      @socket.close if @socket && !@socket.closed?
      begin
        @socket = TCPTimeout::TCPSocket.new(@host, @port, @socket_opts)
      rescue TCPTimeout::SocketTimeout => ex
        raise Rexpro::RexproException.new(ex)
      end
    end

    def request(req)
      req.write_to(@socket)

      Rexpro::Message.read_from(@socket).tap do |resp|
        if resp.request_uuid.bytes.to_a != req.request_uuid.bytes.to_a
          raise Rexpro::RexproException,
                "request uuid of response didn't match request"
        end

        if resp.is_a? Rexpro::Message::Error
          err_msg = resp.error_message
          err_msg << " [flag=#{resp.flag}]" if resp.flag
          raise Rexpro::RexproError.new(err_msg)
        end
      end
    rescue TCPTimeout::SocketTimeout => ex
      raise Rexpro::RexproException.new(ex)
    end

    def new_session(opts = {})
      opts = @request_opts.merge(opts)
      req = Rexpro::Message::SessionRequest.new(opts)
      resp = request(req)
      Rexpro::Session.new(self, resp.session_uuid, req.channel, resp.languages)
    end

    def execute(script, opts = {})
      opts = @request_opts.merge(opts)
      opts[:script] = script
      msg = Rexpro::Message::ScriptRequest.new(opts)
      request(msg)
    end
  end
end
