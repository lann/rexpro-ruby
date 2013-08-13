require "bundler/gem_tasks"

require 'rake/testtask'

task :default => :basic_tests

desc 'Run basic (non-integration) tests'
Rake::TestTask.new(:basic_tests) do |test|
  test.verbose = true
  test.test_files = ['spec/*_spec.rb']
end

desc 'Run integration tests'
Rake::TestTask.new(:integration_tests) do |test|
  test.verbose = true
  test.test_files = ['spec/integration/*_spec.rb']
end

desc 'Run all tests'
Rake::TestTask.new do |test|
  test.verbose = true
  test.test_files = ['spec/**/*_spec.rb']
end

REXSTER_SERVER_URL = 'http://tinkerpop.com/downloads/rexster/rexster-server-2.4.0.zip'

desc 'Install and run rexster-server'
task :run_rexster do
  tmpdir = File.expand_path('../tmp', __FILE__)
  rexster_filename = File.join(tmpdir, 'rexster-server.zip')
  
  unless File.exists? rexster_filename
	FileUtils.mkdir_p tmpdir
	sh "wget '#{REXSTER_SERVER_URL}' -O '#{rexster_filename}'"
  end

  rexster_glob = File.join(tmpdir, 'rexster-server-*/bin')

  if Dir[rexster_glob].empty?
    sh "unzip '#{rexster_filename}' -d '#{tmpdir}'"
  end

  Dir.chdir(File.join(Dir[rexster_glob].first, '..')) do
    sh 'nohup bin/rexster.sh -s > rexster.log &'
  end
end
