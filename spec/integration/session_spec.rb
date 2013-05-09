require 'minitest/autorun'
require_relative './integration_helper'
require 'rexpro'

describe Rexpro::Session do
  include IntegrationHelper

  subject { Rexpro::Client.new(client_opts).new_session }

  it 'is a session' do
    with_connect_notice do
      subject.must_be_instance_of Rexpro::Session
    end
  end

  describe '#execute' do
    it 'executes a script in the session' do
      resp = subject.execute('1')
      resp.session_uuid.must_equal subject.uuid
    end
  end

  describe '#kill' do
    it 'ends the session' do
      resp = subject.kill
      resp.session_uuid.must_equal Rexpro::Message::ZERO_UUID
    end
  end
end
