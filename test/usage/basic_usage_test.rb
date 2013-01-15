require 'test_helper'

class KintamaTest < KintamaIntegrationTest

  def test_should_pass_when_all_tests_pass
    context "Given a test that passes" do
      should "pass the test" do
        assert true
      end
    end.
    should_output(%{
      Given a test that passes
        should pass the test: .
    }).
    and_pass
  end

  def test_should_fail_when_all_tests_fail
    context "Given a test that fails" do
      should "fail the test" do
        flunk
      end
    end.
    should_output(%{
      Given a test that fails
        should fail the test: F
    }).
    and_fail
  end

  def test_should_fail_when_any_tests_fail
    context "Given two tests" do
      should "pass the passing test" do
        flunk
      end

      should "ultimately fail because there is one failing test" do
        assert true
      end
    end.
    should_run_tests(2).
    and_fail
  end

  def test_should_fail_when_any_assertion_within_a_test_fails
    context "Given a test with two assertions" do
      should "fail because one of the assertions doesn't pass" do
        flunk "fail here"
        assert true
      end
    end.
    should_run_tests(1).
    and_fail
  end

  def test_should_not_run_any_code_beyond_a_failing_assertion
    context "Given a test with a failure before the end of the test" do
      should "not execute any test after the test failures" do
        flunk "fail here"
        raise "should not get here!"
      end
    end.
    should_fail.with_failure("fail here")
  end

  def test_should_allow_nesting_of_contexts
    context "Given a context" do
      context "and a subcontext" do
        should "nest this test within the inner context" do
          assert true
        end
      end
    end.
    should_output(%{
      Given a context
        and a subcontext
          should nest this test within the inner context: .
    }).
    and_pass
  end

  def test_should_allow_multiple_subcontexts
    context "Given some contexts" do
      context "one containing failing tests" do
        should "ultimately fail because of the failing test" do
          flunk
        end
      end

      context "one containing passing tests" do
        should "still run the passing test" do
          assert true
        end
      end
    end.
    should_run_tests(2).
    and_output(%{
      Given some contexts
        one containing failing tests
          should ultimately fail because of the failing test: F
        one containing passing tests
          should still run the passing test: .
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
