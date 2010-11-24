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
    failures.empty?
  end

  def failures
    all_tests.select { |t| !t.passed? } + all_subcontexts.map { |s| s.failures }.flatten
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
        @failure = e
      end
      runner.test_finished(self) if runner
    end

    def passed?
      @failure.nil?
    end

    def full_name
      @context.full_name + " " + @name
    end

    def failure_message
      @failure.message
    end
  end

  class TestEnvironment
    def assert(expression, message="failed")
      raise TestFailure, message unless expression
    end

    def flunk
      assert false
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
  INDENT = "  "

  def initialize(*contexts)
    @contexts = contexts
    @current_indent = -1
  end

  def run(verbose=false)
    @verbose = verbose
    @contexts.each do |c|
      @current_indent = -1
      c.run(self)
      puts if @verbose && c != @contexts.last
    end
    show_results
  end

  def indent
    INDENT * @current_indent
  end

  def context_started(context)
    @current_indent += 1
    print indent + context.name + "\n" if @verbose
  end

  def test_started(test)
    print indent + INDENT + test.name + ": " if @verbose
  end

  def test_finished(test)
    print(test.passed? ? "." : "F")
    puts if @verbose
  end

  def failures
    @contexts.map { |c| c.failures }.flatten
  end

  def show_results
    if failures.any?
      print("\n\n")
      failures.each do |test|
        puts test.full_name + ":\n  " + test.failure_message
      end
    else
      puts unless @verbose
    end
  end
end
