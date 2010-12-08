module JTest
  class TestFailure < StandardError; end

  autoload :Context, 'jtest/context'
  autoload :Test, 'jtest/test'
  autoload :TestEnvironment, 'jtest/test_environment'
  autoload :Runner, 'jtest/runner'
  autoload :Assertions, 'jtest/assertions'
  autoload :Aliases, 'jtest/aliases'

  def self.reset
    @contexts = []
  end

  extend Aliases::Context

  def self.contexts
    (@contexts ||= [])
  end

  def self.modules
    (@modules ||= [])
  end

  def self.add(mod=nil, &block)
    if mod.nil?
      mod = Module.new
      mod.class_eval(&block)
    end
    modules << mod
  end

  def self.run(*args)
    Runner.default.run(*args)
  end

  def self.add_exit_hook
    return if @__added_exit_hook
    at_exit { exit(run(true) ? 0 : 1) }
    @__added_exit_hook = true
  end

  def self.test_file_was_run?
    caller.last.split(":").first == $0
  end

  def self.run_via_rake?
    caller.find { |line| File.basename(line.split(":").first) == "rake_test_loader.rb" } != nil
  end

  def self.should_run_on_exit
    return false if ENV["JTEST_EXPLICITLY_DONT_RUN"]
    return test_file_was_run? || run_via_rake?
  end
end

JTest::Aliases::Context.instance_methods.each do |method|
  unless self.respond_to?(method)
    eval %|def #{method}(name, &block); JTest.#{method}(name, nil, &block); end|
  end
end

JTest.add_exit_hook if JTest.should_run_on_exit