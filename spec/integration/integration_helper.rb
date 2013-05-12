module IntegrationHelper
  def client_opts
    %w[host port connect_timeout read_timeout write_timeout
    ].inject({}) do |memo, key|
      if value = ENV["REXPRO_#{key.upcase}"]
        value = value.to_i if value =~ /\A\d+$\z/
        memo[key.to_sym] = value
      end
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
