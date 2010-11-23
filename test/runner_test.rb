require 'test/unit'
require '../jtest'
require 'stringio'

class Runner
  def initialize(context, verbose=false)
    @context = context
    @verbose = verbose
  end
  def run
    @context.run(self)
    puts
  end
  def started(test_or_context)
    if @verbose
      if test_or_context.is_a?(Context)
        print test_or_context.name
      else
        print "\n\t" + test_or_context.name + ": "
      end
    end
  end
  def finished(test)
    print(test.passed? ? "." : "F")
  end
end

class RunnerTest < Test::Unit::TestCase
  def test_assert_output_works
    assert_output("yes\n") do
      puts "yes"
    end
  end

  def test_should_print_out_dots_when_a_test_passes
    c = context "given something" do
      should "pass" do
        assert true
      end
    end
    assert_output(".\n") do
      Runner.new(c).run
    end
  end

  def test_should_print_out_many_dots_as_tests_run
    c = context "given something" do
      should "pass" do
        assert true
      end
      should "also pass" do
        assert true
      end
    end
    assert_output("..\n") do
      Runner.new(c).run
    end
  end

  def test_should_print_out_Fs_as_tests_fail
    c = context "given something" do
      should "fail" do
        assert false
      end
      should "pass" do
        assert true
      end
    end
    assert_output("F.\n") do
      Runner.new(c).run
    end
  end

  def test_should_print_out_test_names_if_verbose_is_set
    c = context "given something" do
      should "fail" do
        assert false
      end
      should "pass" do
        assert true
      end
    end
    assert_output("given something\n\tshould fail: F\n\tshould pass: .\n") do
      Runner.new(c, verbose=true).run
    end
  end

  private

  def context(name, &block)
    Context.new(name, nil, &block)
  end

  module ::Kernel
    def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      out.rewind
      return out
    ensure
      $stdout = STDOUT
    end
  end

  def assert_output(expected, &block)
    assert_equal expected, capture_stdout(&block).read
  end
end