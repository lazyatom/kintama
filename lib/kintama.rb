module Kintama
  autoload :Context, 'kintama/context'
  autoload :Test, 'kintama/test'
  autoload :TestFailure, 'kintama/test'
  autoload :TestEnvironment, 'kintama/test_environment'
  autoload :Runner, 'kintama/runner'
  autoload :Assertions, 'kintama/assertions'
  autoload :Aliases, 'kintama/aliases'

  extend Aliases::Context

  class << self
    # Resets the global state of the test system, removing all contexts, setups,
    # teardowns and included modules
    def reset
      @default_context = Context.new(nil) {}
    end

    def default_context
      @default_context ||= Context.new(nil) {}
    end

    # Makes behaviour available within tests. You can either pass a module:
    #
    #   module SomeModule
    #     def blah
    #     end
    #   end
    #   Kintama.include SomeModule
    #
    # or a block:
    #
    #   Kintama.include do
    #     def blah
    #     end
    #   end
    #
    # Any methods will then be available within setup, teardown or tests.
    def include(mod=nil, &block)
      default_context.include(mod, &block)
    end

    def extend(mod=nil, &block)
      default_context.extend(mod, &block)
    end

    # Add a setup which will run at the start of every test. Multiple global
    # setup blocks can be added, and will be run in order of adding.
    def setup(&block)
      default_context.setup(&block)
    end

    # Add a teardown which will be run at the end of every test. Multiple global
    # teardown blocks can be added, and will be run in reverse order of adding.
    def teardown(&block)
      default_context.teardown(&block)
    end

    # Runs all of the known contexts and tests using the default Runner
    def run(*args)
      default_context.run(*args)
    end

    # Adds the hook to automatically run all known tests using #run when
    # ruby exits; this is most useful when running a test file from the command
    # line or from within an editor
    def add_exit_hook
      return if @__added_exit_hook
      at_exit { exit(Runner.default.run ? 0 : 1) }
      @__added_exit_hook = true
    end

    # Tries to determine whether or not this is a sensible situation to automatically
    # run all tests when ruby exits. At the moment, this is true when either:
    # - the test was run via rake
    # - the test file was run as the top-level ruby script
    #
    # This method will always return false if the environment variable
    # KINTAMA_EXPLICITLY_DONT_RUN is not nil.
    def should_run_on_exit?
      return false if ENV["KINTAMA_EXPLICITLY_DONT_RUN"]
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

Kintama::Aliases::Context.instance_methods.each do |method|
  unless self.respond_to?(method)
    eval %|def #{method}(name, &block); Kintama.#{method}(name, Kintama.default_context, &block); end|
  end
end

Kintama.add_exit_hook if Kintama.should_run_on_exit?