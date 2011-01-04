module Kintama
  autoload :Runnable, 'kintama/runnable'
  autoload :Context, 'kintama/context'
  autoload :Test, 'kintama/test'
  autoload :TestFailure, 'kintama/test'
  autoload :Runner, 'kintama/runner'
  autoload :Assertions, 'kintama/assertions'
  autoload :Aliases, 'kintama/aliases'

  extend Aliases::Context

  class << self
    def reset
      @default_context = Class.new(Runnable)
      @default_context.send(:include, Kintama::Context)
    end

    def default_context
      reset unless @default_context
      @default_context
    end

    # Add a setup which will run at the start of every test.
    def setup(&block)
      default_context.setup(&block)
    end

    # Add a teardown which will be run at the end of every test.
    def teardown(&block)
      default_context.teardown(&block)
    end

    # Makes behaviour available within tests:
    #
    #   module SomeModule
    #     def blah
    #     end
    #   end
    #   Kintama.include SomeModule
    #
    # Any methods will then be available within setup, teardown or tests.
    def include(mod)
      default_context.send(:include, mod)
    end

    # Make new testing behaviour available for the definition of tests.
    # Methods included in this way are available during the definition of tests.
    def extend(mod)
      default_context.extend(mod)
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