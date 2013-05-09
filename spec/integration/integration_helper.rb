module IntegrationHelper
  def client_opts
    %w[host port].inject({}) do |memo, key|
      value = ENV["REXPRO_#{key.upcase}"]
      memo[key.to_sym] = value if value
      memo
    end
  end

  @@notice_shown = false

  def with_connect_notice(&blk)
    yield
  rescue SocketError, Errno::ECONNREFUSED
    unless @@notice_shown
      puts '!' * 65,
           'It looks like the client failed to connect. Make sure a server is',
           'running and that REXPRO_HOST and REXPRO_PORT are set if needed.',
           '!' * 65
      @notice_shown = true
    end
    raise
  end
end
