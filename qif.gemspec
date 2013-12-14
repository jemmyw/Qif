# -*- encoding: utf-8 -*-

include_files = ["README*", "LICENSE", "CHANGELOG", "Rakefile", "{lib,spec}/**/*"].map do |glob|
  Dir[glob]
end.flatten
exclude_files = ["**/*.rbc"].map do |glob|
  Dir[glob]
end.flatten

Gem::Specification.new do |s|
  s.name                      = "qif"
  s.version                   = "1.1.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Jeremy Wells"]
  s.date                      = "2013-12-14"
  s.description               = "A library for reading and writing quicken QIF files."
  s.summary                   = "A library for reading and writing quicken QIF files."
  s.email                     = "jemmyw@gmail.com"
  s.extra_rdoc_files          = ["CHANGELOG", "LICENSE", "README.rdoc", "lib/qif.rb", "lib/qif/date_format.rb", "lib/qif/reader.rb", "lib/qif/transaction.rb", "lib/qif/writer.rb"]
  s.files                     = include_files - exclude_files
  s.homepage                  = "http://qif.github.com/qif"
  s.rdoc_options              = ["--line-numbers", "--inline-source", "--title", "Qif", "--main", "README.rdoc"]
  s.require_path              = "lib"
  s.rubyforge_project         = "qif"
  
  s.add_development_dependency 'rspec', '>= 2.5.0'
end
