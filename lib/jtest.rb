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
    # Resets the global state of the test system, removing all contexts, setups,
    # teardowns and included modules
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

    # Makes behaviour available within tests. You can either pass a module:
    #
    #   module SomeModule
    #     def blah
    #     end
    #   end
    #   JTest.add SomeModule
    #
    # or a block:
    #
    #   JTest.add do
    #     def blah
    #     end
    #   end
    #
    # Any methods will then be available within setup, teardown or tests.
    def add(mod=nil, &block)
      if mod.nil?
        mod = Module.new
        mod.class_eval(&block)
      end
      modules << mod
    end

    # Add a setup which will run at the start of every test. Multiple global
    # setup blocks can be added, and will be run in order of adding.
    def setup(&block)
      setup_blocks << block
    end

    def run_global_setups(environment)
      setup_blocks.each { |b| environment.instance_eval(&b) }
    end

    # Add a teardown which will be run at the end of every test. Multiple global
    # teardown blocks can be added, and will be run in reverse order of adding.
    def teardown(&block)
      teardown_blocks << block
    end

    def run_global_teardowns(environment)
      teardown_blocks.reverse.each { |b| environment.instance_eval(&b) }
    end

    # Runs all of the known contexts and tests using the default Runner
    def run(*args)
      Runner.default.run(*args)
    end

    # Adds the hook to automatically run all known tests using #run when
    # ruby exits; this is most useful when running a test file from the command
    # line or from within an editor
    def add_exit_hook
      return if @__added_exit_hook
      at_exit { exit(run(true) ? 0 : 1) }
      @__added_exit_hook = true
    end

    # Tries to determine whether or not this is a sensible situation to automatically
    # run all tests when ruby exits. At the moment, this is true when either:
    # - the test was run via rake
    # - the test file was run as the top-level ruby script
    #
    # This method will always return false if the environment variable
    # JTEST_EXPLICITLY_DONT_RUN is not nil.
    def should_run_on_exit?
      return false if ENV["JTEST_EXPLICITLY_DONT_RUN"]
      return test_file_was_run? || run_via_rake?
    end

    private

    def test_file_was_run?
      caller.last.split(":").first == $0
    end

    def run_via_rake?
      caller.find { |line| File.basename(line.split(":").first) == "rake_test_loader.rb" } != nil
    end
  end
end

JTest::Aliases::Context.instance_methods.each do |method|
  unless self.respond_to?(method)
    eval %|def #{method}(name, &block); JTest.#{method}(name, nil, &block); end|
  end
end

JTest.add_exit_hook if JTest.should_run_on_exit?