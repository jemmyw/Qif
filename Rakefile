require 'echoe'
require 'rspec/core/rake_task'

Echoe.new('qif') do |gem|
  gem.author = "Jeremy Wells"
  gem.summary = "A library for reading and writing quicken QIF files."
  gem.email = "jemmyw@gmail.com"
end

desc "Run specs"
RSpec::Core::RakeTask.new :spec

task :default => :spec
