require 'test_helper'

class KintamaTest < KintamaIntegrationTest

  def test_should_pass_when_all_tests_pass
    context "Given a test that passes" do
      should "work" do
        assert true
      end
    end.
    should_output(%{
      Given a test that passes
        should work: .
    }).
    and_pass
  end

  def test_should_fail_when_all_tests_fail
    context "Given a test that fails" do
      should "work" do
        flunk
      end
    end.
    should_output(%{
      Given a test that fails
        should work: F
    }).
    and_fail
  end

  def test_should_fail_when_any_tests_fail
    context "Given something" do
      should "work" do
        flunk
      end
      should "also work" do
        assert true
      end
    end.
    should_fail
  end

  def test_should_fail_when_any_assertion_within_a_test_fails
    context "Given something" do
      should "ultimately not work" do
        flunk "fail here"
        assert true
      end
    end.
    should_fail
  end

  def test_should_not_run_any_code_beyond_a_failing_assertion
    context "Given something" do
      should "ultimately not work" do
        flunk "fail here"
        raise "should not get here!"
      end
    end.
    should_fail.with_failure("fail here")
  end

  def test_should_allow_nesting_of_contexts
    context "Given something" do
      context "and another thing" do
        should "work" do
          assert true
        end
      end
    end.
    should_output(%{
      Given something
        and another thing
          should work: .
    }).
    and_pass
  end

  def test_should_allow_multiple_subcontexts
    context "Given some contexts" do
      context "containing failing tests" do
        should "fail" do
          flunk
        end
      end
      context "containing passing tests" do
        should "pass" do
          assert true
        end
      end
    end.
    should_output(%{
      Given some contexts
        containing failing tests
          should fail: F
        containing passing tests
          should pass: .
    }).
    and_fail
  end

  def test_should_allow_deep_nesting_of_subcontexts
    context "Given something" do
      context "and another thing" do
        context "and one more thing" do
          should "work" do
            assert true
          end
        end
      end
    end.
    should_output(%{
      Given something
        and another thing
          and one more thing
            should work: .
    }).
    and_pass
  end
end
