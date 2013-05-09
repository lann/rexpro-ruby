require 'rexpro'

class Rexpro::Session
  attr_reader :client, :uuid, :channel, :languages

  def initialize(client, uuid, channel, languages = nil)
    @client, @uuid, @channel, @languages = client, uuid, channel, languages
  end

  def kill
    attrs = {session_uuid: uuid, kill_session: true}
    msg = Rexpro::Message::SessionRequest.new(attrs)
    client.request(msg)
  end

  def execute(script, attrs = {})
    attrs = attrs.merge(
      session_uuid: uuid, channel: channel, in_session: true, script: script)
    msg = Rexpro::Message::ScriptRequest.new(attrs)
    client.request(msg)
  end
end
