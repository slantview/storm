$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "storm/version"

task :build do
  system "gem build storm.gemspec"
end

task :install do
  Rake::Task["build"].execute
  system "sudo gem install storm-#{Storm::VERSION}"
end

task :release => :build do
  system "gem push deployr-#{Bunder::VERSION}"
end

task :default do
  Rake::Task["install"].execute
end
