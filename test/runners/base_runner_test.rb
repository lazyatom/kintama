require 'test_helper'

class BaseRunnerTest < Kintama_TestUnit_TestCase

  def test_assert_output_works
    assert_output("yes\n") do
      puts "yes"
    end
  end

  def test_should_print_summary_when_a_test_passes
    c = context "given something" do
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^1 tests, 0 failures/, r.test_summary
  end

  def test_should_print_out_summary_when_multiple_tests_pass
    c = context "given something" do
      should "pass" do
        assert true
      end
      should "also pass" do
        assert true
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^2 tests, 0 failures/, r.test_summary
  end

  def test_should_print_out_summary_when_a_pending_test_exists
    c = context "given something" do
      should "pass" do
        assert true
      end
      should "not be implemented yet"
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^2 tests, 0 failures, 1 pending/, r.test_summary
  end

  def test_should_print_out_failure_details_if_tests_fail
    c = context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^1\) given something should fail:\n  flunked\./, r.failure_messages[0]
  end

  def test_should_print_out_the_test_duration
    c = context "given something" do
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^1 tests, 0 failures \(0\.\d+ seconds\)/, r.test_summary
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
    capture_stdout { r.run }
    assert_match /^2 tests, 0 failures/, r.test_summary
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

  def test_should_only_run_each_context_once
    Kintama.reset
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
      assert runner(c).run, "should not have run the context twice"
    end
  end

  def test_should_print_out_the_names_of_tests_that_fail
    c = context "given something" do
      should "fail" do
        flunk
      end
    end
    r = runner(c)
    capture_stdout { r.run }
    assert_match /^1\) given something should fail:\n  flunked\./, r.failure_messages[0]
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
    Kintama::Runner::Base.new(*args)
  end

end