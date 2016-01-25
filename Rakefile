require 'rspec/core/rake_task'
require 'rdoc/task'

desc "Run specs"
RSpec::Core::RakeTask.new :spec

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

task :default => :spec
