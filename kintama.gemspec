# -*- encoding: utf-8 -*-
# stub: kintama 0.1.13 ruby lib

Gem::Specification.new do |s|
  s.name = "kintama".freeze
  s.version = "0.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["James Adam".freeze]
  s.date = "2020-07-09"
  s.email = "james@lazyatom.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze, "lib/kintama".freeze, "lib/kintama.rb".freeze, "lib/kintama/assertions.rb".freeze, "lib/kintama/context.rb".freeze, "lib/kintama/mocha.rb".freeze, "lib/kintama/no_conflict.rb".freeze, "lib/kintama/reporter.rb".freeze, "lib/kintama/runnable.rb".freeze, "lib/kintama/runner.rb".freeze, "lib/kintama/test.rb".freeze, "test/integration".freeze, "test/integration/automatic_running_test.rb".freeze, "test/integration/line_based_running_test.rb".freeze, "test/reporters".freeze, "test/reporters/base_reporter_test.rb".freeze, "test/reporters/inline_reporter_test.rb".freeze, "test/reporters/verbose_reporter_test.rb".freeze, "test/test_helper.rb".freeze, "test/unit".freeze, "test/unit/assertions_test.rb".freeze, "test/unit/context_test.rb".freeze, "test/unit/runner_test.rb".freeze, "test/unit/test_and_subcontext_access_test.rb".freeze, "test/usage".freeze, "test/usage/01_basic_usage_test.rb".freeze, "test/usage/02_setup_test.rb".freeze, "test/usage/03_teardown_test.rb".freeze, "test/usage/04_pending_tests_test.rb".freeze, "test/usage/05_aliases_test.rb".freeze, "test/usage/06_defining_methods_in_tests_test.rb".freeze, "test/usage/07_exceptions_test.rb".freeze, "test/usage/08_start_and_finish_test.rb".freeze, "test/usage/09_expectations_and_mocking_test.rb".freeze, "test/usage/10_let_and_subject_test.rb".freeze, "test/usage/11_matcher_test.rb".freeze, "test/usage/12_action_test.rb".freeze]
  s.homepage = "http://github.com/lazyatom".freeze
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "It's for writing tests.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>.freeze, [">= 1.11.2"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    else
      s.add_dependency(%q<mocha>.freeze, [">= 1.11.2"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>.freeze, [">= 1.11.2"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
  end
end
