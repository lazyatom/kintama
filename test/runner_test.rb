require 'test/unit'
require '../jtest'
require 'stringio'

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
    expected = <<-EOS
F.

given something should fail:
  failed
EOS
    assert_output(expected.strip + "\n") do
      Runner.new(c).run
    end
  end

  def test_should_print_out_test_names_if_verbose_is_set
    c = context "given something" do
      should "also pass" do
        assert true
      end
      should "pass" do
        assert true
      end
    end
    assert_output("given something\n  should also pass: .\n  should pass: .\n") do
      Runner.new(c).run(verbose=true)
    end
  end

  def test_should_nest_printed_context_and_test_names_if_verbose_is_set
    c = context "given something" do
      should "pass" do
        assert true
      end
      context "and something else" do
        should "pass" do
          assert true
        end
      end
    end
    assert_output("given something\n  should pass: .\n  and something else\n    should pass: .\n") do
      Runner.new(c).run(verbose=true)
    end
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_some_fail
    c = context "given something" do
      should "fail" do
        assert 1 == 2, "1 should equal 2"
      end
    end
    expected = <<-EOS
F

given something should fail:
  1 should equal 2
EOS
    assert_output(expected.strip + "\n") { Runner.new(c).run }
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_a_nested_test_fails
    c = context "given something" do
      context "and something else" do
        should "fail" do
          assert 1 == 2, "1 should equal 2"
        end
      end
    end
    expected = <<-EOS
F

given something and something else should fail:
  1 should equal 2
EOS
    assert_output(expected.strip + "\n") { Runner.new(c).run }
  end

  def test_should_be_able_to_run_tests_from_several_contexts
    c1 = context "given something" do
      should "pass" do
        assert true
      end
    end
    c2 = context "given another thing" do
      should "also pass" do
        assert true
      end
    end
    assert_output("..\n") do
      Runner.new(c1, c2).run
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