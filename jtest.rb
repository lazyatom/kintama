class Context
  attr_reader :name

  def initialize(name, parent=nil, &block)
    @name = name
    @block = block
    @subcontexts = {}
    @tests = {}
    @parent = parent
    instance_eval(&@block)
  end

  def run(runner=nil)
    runner.context_started(self) if runner
    all_tests.each { |t| t.run(runner) }
    all_subcontexts.each { |s| s.run(runner) }
  end

  def context(name, &block)
    @subcontexts[methodize(name)] = self.class.new(name, self, &block)
  end

  def setup(&setup_block)
    @setup_block = setup_block
  end

  def run_setups(environment)
    @parent.run_setups(environment) if @parent
    environment.instance_eval(&@setup_block) if @setup_block
  end

  def should(name, &block)
    full_name = "should " + name
    @tests[methodize(full_name)] = Test.new(full_name, self, &block)
  end

  def passed?
    failures.empty? && all_subcontexts.inject(true) { |result, s| result && s.passed? }
  end

  def failures
    all_tests.select { |t| !t.passed? }
  end

  def method_missing(name, *args)
    @subcontexts[name] || @tests[name]
  end

  class TestFailure < StandardError; end

  class Test
    attr_accessor :name, :failure

    def initialize(name, context, &block)
      @name = name
      @context = context
      @test_block = block
      @failure = nil
    end

    def run(runner=nil)
      runner.test_started(self) if runner
      environment = TestEnvironment.new
      @context.run_setups(environment)
      begin
        environment.instance_eval(&@test_block)
      rescue TestFailure => e
        @failure = e.message
      end
      runner.test_finished(self) if runner
    end

    def passed?
      @failure.nil?
    end
  end

  class TestEnvironment
    def assert(expression, message="failed")
      raise TestFailure, message unless expression
    end

    def assert_equal(expected, actual)
      assert actual == expected, "Expected #{expected.inspect} but got #{actual.inspect}"
    end
  end

  private

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

class Runner
  def initialize(context, verbose=false)
    @context = context
    @verbose = verbose
    @current_indent = -1
  end

  def run
    @context.run(self)
  end

  def indent
    "\t" * @current_indent
  end

  def context_started(context)
    @current_indent += 1
    print indent + context.name + "\n" if @verbose
  end

  def test_started(test)
    print indent + "\t" + test.name + ": " if @verbose
  end

  def test_finished(test)
    print(test.passed? ? "." : "F")
    puts if @verbose
  end
end
