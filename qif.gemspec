# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{qif}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Wells"]
  s.date = %q{2011-03-07}
  s.description = %q{A library for reading and writing quicken QIF files.}
  s.email = %q{jemmyw@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.rdoc", "lib/qif.rb", "lib/qif/date_format.rb", "lib/qif/reader.rb", "lib/qif/transaction.rb", "lib/qif/writer.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "QIF_references", "README.rdoc", "Rakefile", "lib/qif.rb", "lib/qif/date_format.rb", "lib/qif/reader.rb", "lib/qif/transaction.rb", "lib/qif/writer.rb", "spec/fixtures/3_records_ddmmyy.qif", "spec/fixtures/3_records_ddmmyyyy.qif", "spec/fixtures/3_records_dmyy.qif", "spec/fixtures/3_records_invalid_header.qif", "spec/fixtures/3_records_mmddyy.qif", "spec/fixtures/3_records_mmddyyyy.qif", "spec/fixtures/3_records_separator.qif", "spec/fixtures/not_a_QIF_file.txt", "spec/fixtures/quicken_investment_account.qif", "spec/fixtures/quicken_non_investement_account.qif", "spec/lib/date_format_spec.rb", "spec/lib/reader_spec.rb", "spec/lib/transaction_spec.rb", "spec/lib/writer_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "qif.gemspec"]
  s.homepage = %q{http://qif.github.com/qif/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Qif", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{qif}
  s.rubygems_version = %q{1.6.1}
  s.summary = %q{A library for reading and writing quicken QIF files.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
