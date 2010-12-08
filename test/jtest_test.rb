require 'test_helper'

class JTestTest < JTest_TestUnit_TestCase

  def test_should_pass_when_all_tests_pass
    x = context "Given something" do
      should "work" do
        assert true
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_fail_when_all_tests_fail
    x = context "Given something" do
      should "work" do
        flunk
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_fail_when_any_tests_fail
    x = context "Given something" do
      should "work" do
        flunk
      end
      should "also work" do
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_fail_when_any_assertion_within_a_test_fails
    x = context "Given something" do
      should "ultimately not work" do
        flunk
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_not_run_any_code_beyond_a_failing_assertion
    x = context "Given something" do
      should "ultimately not work" do
        flunk
        raise "should not get here!"
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_nesting_of_contexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          flunk
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_multiple_subcontexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          flunk
        end
      end
      context "and another different thing" do
        should "work" do
          assert true
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_deep_nesting_of_subcontexts
    x = context "Given something" do
      context "and another thing" do
        context "and one more thing" do
          should "work" do
            flunk
          end
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_clear_previous_failure_when_running_test_again
    $thing = 456
    x = context "Given something" do
      should "work" do
        assert_equal 123, $thing
      end
    end
    assert_equal false, x.run
    $thing = 123
    assert_equal true, x.run
  end
end