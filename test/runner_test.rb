require 'test_helper'

require 'stringio'

class RunnerTest < JTest_TestUnit_TestCase

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
    r = runner(c)
    assert_output(/^\.\n/) do
      r.run
    end
    assert_equal "1 tests, 0 failures", r.test_summary
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
    r = runner(c)
    assert_output(/^\.\.\n/) do
      r.run
    end
    assert_equal "2 tests, 0 failures", r.test_summary
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
    r = runner(c)
    assert_output(/^F\./) do
      r.run
    end
    assert_equal "2 tests, 1 failures", r.test_summary
    assert_match /^1\) given something should fail:\n  flunked\./, r.failure_messages[0]
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
    assert_output(/^given something\n  should also pass: \.\n  should pass: \./) do
      runner(c).run(verbose=true, false)
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
      context "and then this" do
        should "also pass" do
          assert true
        end
      end
    end
    assert_output(/^given something\n  should pass: \.\n  and then this\n    should also pass: \.\n  and something else\n    should pass: \./) do
      runner(c).run(verbose=true, false)
    end
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_some_fail
    c = context "given something" do
      should "fail" do
        assert 1 == 2, "1 should equal 2"
      end
    end
    assert_output(/given something should fail:\n  1 should equal 2/) { runner(c).run }
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_an_exception_occurs_in_a_test
    c = context "given something" do
      should "fail" do
        raise "unexpected issue!"
      end
    end
    assert_output(/given something should fail:\n  unexpected issue!/) { runner(c).run }
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_a_nested_test_fails
    c = context "given something" do
      context "and something else" do
        should "fail" do
          assert 1 == 2, "1 should equal 2"
        end
      end
    end
    assert_output(/given something and something else should fail:\n  1 should equal 2/) { runner(c).run }
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
    r = runner(c1, c2)
    assert_output(/^\.\.\n/) do
      r.run
    end
    assert_equal "2 tests, 0 failures", r.test_summary
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
    assert_output(/^given something\n  should pass: \.\n\ngiven another thing\n  should also pass: \./) do
      runner(c1, c2).run(verbose=true, false)
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
    assert_output(/^given something\n\e\[31m  should fail\e\[0m\n\e\[32m  should pass\e\[0m/) do
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
    assert_output(/^In a world without hope\n  given a massive gun\n    it should work out well in the end: \./) do
      runner(c).run(verbose=true, false)
    end
  end

  def test_should_only_run_each_context_once_with_the_default_runner
    JTest.reset
    $already_run = false
    c = context "Given something" do
      context "and a thing" do
        should "only run this once" do
          flunk if $already_run
          $already_run = true
        end
      end
    end
    capture_stdout do
      assert JTest::Runner.default.run, "should not have run the context twice"
    end
  end

  def test_should_include_line_in_test_of_error_in_failure_message
    c = context "given jazz" do
      should "tapdance" do
        $line = __LINE__; flunk
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /at #{Regexp.escape(__FILE__)}:#{$line}/, r.failure_messages.first
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
    output = capture_stdout(&block).read
    if expected.is_a?(Regexp)
      assert_match expected, output
    else
      assert_equal expected, output
    end
  end
end