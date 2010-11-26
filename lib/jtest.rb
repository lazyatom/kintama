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
end

unless respond_to?(:context)
  def context(*args, &block)
    JTest.context(*args, &block)
  end
end