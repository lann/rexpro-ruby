require 'msgpack'
require 'uuid'

# https://github.com/tinkerpop/rexster/wiki/RexPro-Messages

module Rexpro
  module Message
    PROTOCOL_VERSION = 1

    SERIALIZER_MSGPACK = 0
    SERIALIZER_JSON    = 1

    ZERO_UUID = [0, 0, 0, 0].pack('NNNN')

    TYPE_ERROR            = 0
    TYPE_SESSION_REQUEST  = 1
    TYPE_SESSION_RESPONSE = 2
    TYPE_SCRIPT_REQUEST   = 3
    TYPE_SCRIPT_RESPONSE  = 5

    class << self
      def generate_uuid
        @uuid ||= UUID.new
        hex = @uuid.generate(:compact)
        ints = hex.each_char.each_slice(8).map { |h| Integer(h.join, 16) }
        ints.pack('NNNN')
      end

      def types
        @types ||= {}
      end

      def read_from(io)
        version = io.readbyte
        if version != PROTOCOL_VERSION
          raise RexproException, "Unknown protocol version #{version}"
        end

        header = io.read(10)
        if header.nil? || header.size < 10
          raise RexproException, "Unexpected EOF: #{header.inspect}"
        end

        serializer_type, reserved, type, size = header.unpack('CNCN')
        type_class = types[type]
        unless type_class
          raise RexproException, "Unknown message type #{type}"
        end
        fields = type_class.fields

        unpacker = MessagePack::Unpacker.new(io)
        array_size = unpacker.read_array_header
        if array_size != fields.length
          raise RexproException,
                "Expected #{fields.length} fields, got #{array_size}"
        end

        attrs = fields.inject({}) do |memo, field|
          memo[field] = unpacker.read
          memo
        end

        attrs[:serializer_type] = serializer_type

        type_class.new(attrs)
      end
    end

    module Base
      def self.included(klass)
        klass.extend ClassMethods
        klass.define_fields session_uuid: :to_s, request_uuid: :to_s,
                            meta: :to_hash
      end

      module ClassMethods
        attr_reader :type

        def type=(type)
          @type = type
          Message.types[type] = self
        end

        def fields
          @fields ||= []
        end

        def field_methods
          @field_methods ||= {}
        end

        def define_fields(hsh)
          hsh.each do |name, method|
            fields << name
            field_methods[name] = method
            attr_accessor(name)
          end
        end

        def define_meta_fields(*names)
          names.each do |name|
            # RexPro uses mixedCase keys in meta
            name_parts = name.to_s.split('_')
            name_parts[1..-1].each(&:capitalize!)
            rexpro_name = name_parts.join

            define_method(name) { meta[rexpro_name] }
            define_method("#{name}=") { |value| meta[rexpro_name] = value }
          end
        end
      end

      attr_reader :serializer_type

      def initialize(attrs = {})
        @serializer_type = attrs.delete(:serializer_type) || SERIALIZER_MSGPACK
        self.meta ||= {}
        attrs.each { |k, v| send("#{k}=", v) }
        self.session_uuid ||= ZERO_UUID
        self.request_uuid ||= Message.generate_uuid
      end

      def serialize_body(*args)
        if serializer_type != SERIALIZER_MSGPACK
          raise NotImplementedError, 'only MsgPack serialization is supported'
        end

        self.class.fields.map do |field|
          value = send(field)
          field_method = self.class.field_methods[field]
          value = value.send(field_method) if field_method
          value
        end.to_msgpack(*args)
      end

      def write_to(io)
        body = serialize_body
        header = [
          PROTOCOL_VERSION, serializer_type, 0, self.class.type, body.size
          ].pack('CCNCN')
        io.write(header + body)
      end
    end

    class Error
      include Base
      self.type = TYPE_ERROR
      define_fields error_message: :to_s
      define_meta_fields :flag
    end

    class SessionRequest
      include Base
      self.type = TYPE_SESSION_REQUEST
      define_fields username: :to_s, password: :to_s
      define_meta_fields :graph_name, :graph_obj_name, :kill_session
    end

    class SessionResponse
      include Base
      self.type = TYPE_SESSION_RESPONSE
      define_fields languages: :to_a
      define_meta_fields :graph_name, :graph_obj_name, :kill_session
    end

    class ScriptRequest
      include Base
      self.type = TYPE_SCRIPT_REQUEST
      define_fields language_name: :to_s, script: :to_s, bindings: :to_hash
      define_meta_fields :in_session, :isolate, :transaction,
                         :graph_name, :graph_obj_name, :console

      def initialize(*_)
        super
        self.language_name ||= 'groovy'
        self.bindings ||= {}
      end
    end

    class ScriptResponse
      include Base
      self.type = TYPE_SCRIPT_RESPONSE
      define_fields results: nil, bindings: :to_hash
    end
  end
end
