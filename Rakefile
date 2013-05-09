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
