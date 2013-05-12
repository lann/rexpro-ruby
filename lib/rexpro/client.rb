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

    def new_session(*args)
      req = Rexpro::Message::SessionRequest.new(*args)
      resp = request(req)
      Rexpro::Session.new(self, resp.session_uuid, req.channel, resp.languages)
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

    def execute(script, attrs = {})
      attrs = attrs.merge(script: script)
      msg = Rexpro::Message::ScriptRequest.new(attrs)
      request(msg)
    end
  end
end
