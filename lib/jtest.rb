module JTest
  class TestFailure < StandardError; end

  autoload :Context, 'jtest/context'
  autoload :Test, 'jtest/test'
  autoload :TestEnvironment, 'jtest/test_environment'
  autoload :Runner, 'jtest/runner'
  autoload :Assertions, 'jtest/assertions'
  autoload :Aliases, 'jtest/aliases'

  extend Aliases::Context

  class << self
    def reset
      @contexts = []
      @modules = []
      @setup_blocks = []
      @teardown_blocks = []
    end

    def contexts
      (@contexts ||= [])
    end

    def modules
      (@modules ||= [])
    end

    def setup_blocks
      (@setup_blocks ||= [])
    end

    def teardown_blocks
      (@teardown_blocks ||= [])
    end

    def add(mod=nil, &block)
      if mod.nil?
        mod = Module.new
        mod.class_eval(&block)
      end
      modules << mod
    end

    def setup(&block)
      setup_blocks << block
    end

    def run_global_setups(environment)
      setup_blocks.each { |b| environment.instance_eval(&b) }
    end

    def teardown(&block)
      teardown_blocks << block
    end

    def run_global_teardowns(environment)
      teardown_blocks.reverse.each { |b| environment.instance_eval(&b) }
    end

    def run(*args)
      Runner.default.run(*args)
    end

    def add_exit_hook
      return if @__added_exit_hook
      at_exit { exit(run(true) ? 0 : 1) }
      @__added_exit_hook = true
    end

    def test_file_was_run?
      caller.last.split(":").first == $0
    end

    def run_via_rake?
      caller.find { |line| File.basename(line.split(":").first) == "rake_test_loader.rb" } != nil
    end

    def should_run_on_exit
      return false if ENV["JTEST_EXPLICITLY_DONT_RUN"]
      return test_file_was_run? || run_via_rake?
    end
  end
end

JTest::Aliases::Context.instance_methods.each do |method|
  unless self.respond_to?(method)
    eval %|def #{method}(name, &block); JTest.#{method}(name, nil, &block); end|
  end
end

JTest.add_exit_hook if JTest.should_run_on_exit