require 'minitest/autorun'
require_relative './integration_helper'
require 'rexpro'

describe Rexpro::Client do
  include IntegrationHelper

  subject { Rexpro::Client.new(client_opts) }

  it 'connects' do
    with_connect_notice do
      subject.socket.closed?.must_equal false
    end
  end

  describe '#new_session' do
    it 'opens a new session' do
      session = subject.new_session
      session.uuid.bytesize.must_equal 16
    end
  end

  describe '#execute' do
    it 'executes a script' do
      resp = subject.execute('1')
      resp.results.must_equal 1
    end

    it 'raises errors' do
      proc do
        subject.execute(']invalid script[')
      end.must_raise Rexpro::RexproError
    end
  end
end
