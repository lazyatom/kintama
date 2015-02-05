# -*- encoding: utf-8 -*-
# stub: kintama 0.1.12 ruby lib

Gem::Specification.new do |s|
  s.name = "kintama"
  s.version = "0.1.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["James Adam"]
  s.date = "2015-02-05"
  s.email = "james@lazyatom.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "lib/kintama", "lib/kintama.rb", "lib/kintama/assertions.rb", "lib/kintama/context.rb", "lib/kintama/mocha.rb", "lib/kintama/no_conflict.rb", "lib/kintama/reporter.rb", "lib/kintama/runnable.rb", "lib/kintama/runner.rb", "lib/kintama/test.rb", "test/integration", "test/integration/automatic_running_test.rb", "test/integration/line_based_running_test.rb", "test/reporters", "test/reporters/base_reporter_test.rb", "test/reporters/inline_reporter_test.rb", "test/reporters/verbose_reporter_test.rb", "test/test_helper.rb", "test/unit", "test/unit/assertions_test.rb", "test/unit/context_test.rb", "test/unit/runner_test.rb", "test/unit/test_and_subcontext_access_test.rb", "test/usage", "test/usage/01_basic_usage_test.rb", "test/usage/02_setup_test.rb", "test/usage/03_teardown_test.rb", "test/usage/04_pending_tests_test.rb", "test/usage/05_aliases_test.rb", "test/usage/06_defining_methods_in_tests_test.rb", "test/usage/07_exceptions_test.rb", "test/usage/08_start_and_finish_test.rb", "test/usage/09_expectations_and_mocking_test.rb", "test/usage/10_let_and_subject_test.rb", "test/usage/11_matcher_test.rb", "test/usage/12_action_test.rb"]
  s.homepage = "http://github.com/lazyatom"
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.2.2"
  s.summary = "It's for writing tests."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0.13.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0.13.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0.13.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
