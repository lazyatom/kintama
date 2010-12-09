module Kintama
  class Context
    include Aliases::Context

    attr_reader :name

    def initialize(name, parent=nil, &block)
      @name = name
      @subcontexts = {}
      @tests = {}
      @parent = parent
      @parent.add_subcontext(self) if @parent
      @modules = []
      instance_eval(&block)
    end

    # Define the setup for this context.
    # It will also be run for any subcontexts, before their own setup blocks
    def setup(&setup_block)
      @setup_block = setup_block
    end

    # Define the teardown for this context.
    # It will also be run for any subcontexts, after their own teardown blocks
    def teardown(&teardown_block)
      @teardown_block = teardown_block
    end

    # Include a module in this context. Methods on that module will be available during
    # setup, tests and teardowns in this and any subcontexts.
    def include(mod=nil, &block)
      if mod.nil?
        mod = Module.new
        mod.class_eval(&block)
      end
      @modules << mod
    end

    # Define a test to run in this context. The test name will start with "should "
    def should(name, &block)
      add_test("should " + name, &block)
    end

    # Define a test to run in this context. The test name will start with "it "
    def it(name, &block)
      add_test("it " + name, &block)
    end

    # Define a test to run in this context.
    def test(name, &block)
      add_test(name, &block)
    end

    # Returns the full name of this context, taking any parent contexts into account
    def full_name
      if @name
        [@parent ? @parent.full_name : nil, @name].compact.join(" ")
      else
        nil
      end
    end

    # Runs all tests in this context and any subcontexts.
    # Returns true if all tests passed; otherwise false
    def run(runner=nil)
      runner.context_started(self) if runner
      tests.each { |t| t.run(runner) }
      subcontexts.each { |s| s.run(runner) }
      runner.context_finished(self) if runner
      passed?
    end

    # Returns true if this context has no known failed tests.
    def passed?
      failures.empty?
    end

    # Returns an array of tests in this and all subcontexts which failed in
    # the previous run
    def failures
      tests.select { |t| !t.passed? } + subcontexts.map { |s| s.failures }.flatten
    end

    def [](name)
      @subcontexts[name] || @tests[name]
    end

    def method_missing(name, *args, &block)
      if @subcontexts[name]
        @subcontexts[name]
      elsif @tests[name]
        @tests[name]
      else
        begin
          super
        rescue NoMethodError => e
          if @parent
            @parent.send(name, *args, &block)
          else
            raise e
          end
        end
      end
    end

    def respond_to?(name)
      @subcontexts[name] != nil ||
      @tests[name] != nil ||
      super ||
      (@parent ? @parent.respond_to?(name) : false)
    end

    # Returns all subcontexts of this context, in alphabetical order
    def subcontexts
      @subcontexts.values.uniq.sort_by { |c| c.name }
    end

    # Returns all tests defined in this context (but not subcontexts), in alphabetical order
    def tests
      @tests.values.uniq.sort_by { |t| t.name }
    end

    def inspect
      test_names = tests.map { |t| t.name }
      context_names = subcontexts.map { |c| c.name }
      "<Context:#{@name.inspect} @tests=#{test_names.inspect} @subcontexts=#{context_names.inspect}>"
    end

    def run_setups(environment)
      @parent.run_setups(environment) if @parent
      include_modules(environment)
      environment.instance_eval(&@setup_block) if @setup_block
    end

    def run_teardowns(environment)
      environment.instance_eval(&@teardown_block) if @teardown_block
      @parent.run_teardowns(environment) if @parent
    end

    protected

    def add_subcontext(subcontext)
      @subcontexts[subcontext.name] = subcontext
      @subcontexts[methodize(subcontext.name)] = subcontext
    end

    private

    def add_test(name, &block)
      test = Test.new(name, self, &block)
      @tests[methodize(name)] = test
      @tests[name] = test
    end

    def include_modules(environment)
      @modules.each { |mod| environment.extend(mod) }
    end

    def methodize(name)
      name.gsub(" ", "_").to_sym
    end
  end
end