# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jtest}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Adam"]
  s.date = %q{2010-11-26}
  s.email = %q{james@lazyatom.com}
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "test/assertions_test.rb", "test/jtest_test.rb", "test/runner_test.rb", "lib/jtest/assertions.rb", "lib/jtest/context.rb", "lib/jtest/run.rb", "lib/jtest/runner.rb", "lib/jtest/test.rb", "lib/jtest/test_environment.rb", "lib/jtest.rb"]
  s.homepage = %q{http://github.com/lazyatom}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{It's for writing tests.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
