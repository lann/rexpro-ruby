# encoding: utf-8

require 'minitest/autorun'
require 'stringio'

require 'rexpro'

describe Rexpro::Message do
  describe '.generate_uuid' do
    let(:uuid) { Rexpro::Message.generate_uuid }

    it 'generates 16 byte strings' do
      uuid.bytesize.must_equal 16
    end

    it 'generates unique strings' do
      uuid.wont_equal Rexpro::Message.generate_uuid
    end
  end

  describe '.read_from' do
    let(:data) { "\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00/\x94\xB0" +
                 "1234567812345678\xB0abcdefghijklmnop\x81\xA4flag\a\xA4boom" }
    let(:io) { StringIO.new data }
    let(:msg) { Rexpro::Message.read_from(io) }

    it 'correctly parses data' do
      msg.must_be_instance_of Rexpro::Message::Error
      msg.session_uuid.must_equal '1234567812345678'
      msg.request_uuid.must_equal 'abcdefghijklmnop'
      msg.error_message.must_equal 'boom'
      msg.flag.must_equal 7
    end

    it 'is symmetrical with #write_to' do
      out = StringIO.new ''
      msg.write_to(out)
      out.string.must_equal data
    end
  end
end

describe Rexpro::Message::SessionRequest do
  let(:request_uuid) { '1234567812345678' }
  subject { Rexpro::Message::SessionRequest.new request_uuid: request_uuid }

  describe '#write_to' do
    let(:io) { StringIO.new '' }

    it 'correctly writes to the io object' do
      subject.session_uuid = 'abcdefghijklmnop'
      subject.write_to(io)
      io.string.must_equal "\x01\x00\x00\x00\x00\x00\x01\x00\x00\x00&\x95\xB0abcdefghijklmnop" +
                           "\xB01234567812345678\x80\xA0\xA0"
    end

    it 'is symmetrical with .read_from' do
      subject.write_to(io)
      io.rewind
      msg = Rexpro::Message.read_from(io)
      msg.must_be_instance_of Rexpro::Message::SessionRequest
      msg.request_uuid.must_equal subject.request_uuid
    end
  end
end
