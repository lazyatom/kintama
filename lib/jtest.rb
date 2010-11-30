module JTest
  class TestFailure < StandardError; end

  autoload :Context, 'jtest/context'
  autoload :Test, 'jtest/test'
  autoload :TestEnvironment, 'jtest/test_environment'
  autoload :Runner, 'jtest/runner'
  autoload :Assertions, 'jtest/assertions'

  def self.reset
    @contexts = []
  end

  def self.context(name, &block)
    Context.new(name, nil, &block)
  end

  def self.contexts
    (@contexts ||= [])
  end

  def self.run(*args)
    Runner.default.run(*args)
  end

  def self.add_exit_hook
    return if @__added_exit_hook
    at_exit { exit(run(true) ? 0 : 1) }
    @__added_exit_hook = true
  end

  def self.should_run_on_exit
    caller[1].split(":").first == $0 && (ENV["JTEST_EXPLICITLY_DONT_RUN"] != "true")
  end
end

unless self.respond_to?(:context)
  def context(name, &block)
    JTest.context(name, &block)
  end
end

unless self.respond_to?(:given)
  def given(name, &block)
    JTest.context("given " + name, &block)
  end
end

JTest.add_exit_hook if JTest.should_run_on_exit