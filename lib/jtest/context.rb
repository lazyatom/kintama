module JTest
  class Context
    attr_reader :name

    def initialize(name, parent=nil, &block)
      @name = name
      @subcontexts = {}
      @tests = {}
      @parent = parent
      instance_eval(&block)
    end

    def full_name
      [@parent ? @parent.full_name : nil, @name].compact.join(" ")
    end

    def run(runner=nil)
      runner.context_started(self) if runner
      all_tests.each { |t| t.run(runner) }
      all_subcontexts.each { |s| s.run(runner) }
    end

    def context(name, &block)
      @subcontexts[methodize(name)] = self.class.new(name, self, &block)
    end

    def given(name, &block)
      context("given " + name, &block)
    end

    def setup(&setup_block)
      @setup_block = setup_block
    end

    def run_setups(environment)
      @parent.run_setups(environment) if @parent
      environment.instance_eval(&@setup_block) if @setup_block
    end

    def should(name, &block)
      add_test("should " + name, &block)
    end

    def it(name, &block)
      add_test("it " + name, &block)
    end

    def passed?
      failures.empty?
    end

    def failures
      all_tests.select { |t| !t.passed? } + all_subcontexts.map { |s| s.failures }.flatten
    end

    def include(mod)
      extend(mod)
    end

    def method_missing(name, *args, &block)
      if @subcontexts[name]
        @subcontexts[name]
      elsif @tests[name]
        @tests[name]
      elsif @parent
        @parent.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to?(name)
      @subcontexts[name] != nil || 
      @tests[name] != nil || 
      (@parent ? @parent.respond_to?(name) : super)
    end

    private

    def add_test(name, &block)
      @tests[methodize(name)] = Test.new(name, self, &block)
    end

    def methodize(name)
      name.gsub(" ", "_").to_sym
    end

    def all_subcontexts
      @subcontexts.values
    end

    def all_tests
      @tests.values.sort_by { |t| t.name }
    end
  end
end