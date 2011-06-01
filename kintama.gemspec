# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kintama}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Adam"]
  s.date = %q{2011-06-01}
  s.email = %q{james@lazyatom.com}
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "test/aliases_test.rb", "test/assertions_test.rb", "test/automatic_running_test.rb", "test/exceptions_test.rb", "test/kintama_test.rb", "test/line_based_running_test.rb", "test/matcher_test.rb", "test/method_behaviour_test.rb", "test/pending_test_and_context.rb", "test/reporters/base_reporter_test.rb", "test/reporters/inline_reporter_test.rb", "test/reporters/verbose_reporter_test.rb", "test/setup_test.rb", "test/start_and_finish_test.rb", "test/teardown_test.rb", "test/test_and_subcontext_access_test.rb", "test/test_helper.rb", "lib/kintama/assertions.rb", "lib/kintama/context.rb", "lib/kintama/mocha.rb", "lib/kintama/reporter.rb", "lib/kintama/runnable.rb", "lib/kintama/runner.rb", "lib/kintama/test.rb", "lib/kintama.rb"]
  s.homepage = %q{http://github.com/lazyatom}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{It's for writing tests.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
