$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'
require 'jtest'
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
    assert_output(".\n\n1 tests, 0 failures\n") do
      runner(c).run
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
    assert_output("..\n\n2 tests, 0 failures\n") do
      runner(c).run
    end
  end

  def test_should_print_out_Fs_as_tests_fail
    c = context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end
    expected = <<-EOS
F.

2 tests, 1 failures

given something should fail:
  failed
EOS
    assert_output(expected.strip + "\n") do
      runner(c).run
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
    assert_output("given something\n  should also pass: .\n  should pass: .\n\n2 tests, 0 failures\n") do
      runner(c).run(verbose=true)
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
    assert_output("given something\n  should pass: .\n  and something else\n    should pass: .\n\n2 tests, 0 failures\n") do
      runner(c).run(verbose=true)
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

1 tests, 1 failures

given something should fail:
  1 should equal 2
EOS
    assert_output(expected.strip + "\n") { runner(c).run }
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

1 tests, 1 failures

given something and something else should fail:
  1 should equal 2
EOS
    assert_output(expected.strip + "\n") { runner(c).run }
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
    assert_output("..\n\n2 tests, 0 failures\n") do
      runner(c1, c2).run
    end
  end

  def test_should_nest_verbose_output_properly_when_running_tests_from_several_contexts
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
    expected = <<-EOS
given something
  should pass: .

given another thing
  should also pass: .

2 tests, 0 failures
EOS
    assert_output(expected.strip + "\n") do
      runner(c1, c2).run(verbose=true)
    end
  end

  def test_should_print_out_test_names_in_colour_if_verbose_is_set_and_colour_is_set
    c = context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end
    expected = <<-EOS
given something
\e[31m  should fail\e[0m
\e[32m  should pass\e[0m

2 tests, 1 failures

given something should fail:
  failed
EOS
    assert_output(expected.strip + "\n") do
      runner(c).run(verbose=true, colour=true)
    end
  end

  def test_should_return_true_if_all_tests_pass
    c = context "given something" do
      should("pass") { assert true }
      should("also pass") { assert true }
    end
    capture_stdout do
      assert_equal true, runner(c).run
    end
  end

  def test_should_return_false_if_any_tests_fails
    c = context "given something" do
      should("pass") { assert true }
      should("fail") { flunk }
    end
    capture_stdout do
      assert_equal false, runner(c).run
    end
  end

  def test_should_print_appropriate_test_names_when_given_and_it_aliases_are_used
    c = context "In a world without hope" do
      given "a massive gun" do
        it "should work out well in the end" do
          assert true
        end
      end
    end
    expected = <<-EOS
In a world without hope
  given a massive gun
    it should work out well in the end: .

1 tests, 0 failures
EOS
    assert_output(expected.strip + "\n") do
      runner(c).run(verbose=true)
    end
  end

  private

  def runner(*args)
    JTest::Runner.new(*args)
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