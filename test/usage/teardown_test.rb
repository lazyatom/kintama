require 'test_helper'

class TeardownTest < KintamaIntegrationTest

  def setup
    $called = false
  end

  def test_should_run_teardown_after_the_test_finishes
    context "Given a teardown" do
      teardown do
        raise "Argh" unless @result == 123
        $called = true
      end
      should "run teardown after this test" do
        @result = 123
      end
    end.should_pass

    assert $called
  end

  def test_should_run_all_teardowns_in_proximity_of_nesting_order_after_a_nested_test_finishes
    context "Given a teardown" do
      teardown do
        raise "Argh" unless @result == 123
        $called = true
      end
      context "with a subcontext with another teardown" do
        teardown do
          raise "Oh no" unless @result == 456
          @result = 123
        end
        should "run teardown after this test" do
          @result = 456
        end
      end
    end.should_pass

    assert $called
  end

  def test_should_run_teardown_defined_on_kintama_itself_after_other_teardowns
    Kintama.teardown do
      $called = true
      assert_equal 'blah', @thing
    end
    context "Given a context" do
      should "have run the setup defined in the default behaviour" do
        # nothing
      end
      teardown do
        @thing = 'blah'
      end
    end.should_pass

    assert $called
  end

  def test_should_allow_multiple_teardowns_to_be_registered
    Kintama.teardown do
      $ran = 1
    end
    Kintama.teardown do
      $ran += 1
    end
    context "Given multiple setups" do
      should "run them all" do
        assert true
      end
    end.should_pass

    assert_equal 2, $ran, "both teardowns didn't run"
  end

  def test_should_run_teardowns_even_after_exceptions
    context "Given a test that fails" do
      should "still run teardown" do
        raise "argh"
      end
      teardown do
        $called = true
      end
    end.
    should_output(%{
      Given a test that fails
        should still run teardown: F
    }).
    and_fail

    assert $called
  end

  def test_should_not_mask_exceptions_in_tests_with_ones_in_teardown
    context "Given a test and teardown that fails" do
      should "report the error in the test" do
        raise "exception from test"
      end
      teardown do
        raise "exception from teardown"
      end
    end.
    should_output(%{
      Given a test and teardown that fails
        should report the error in the test: F
    }).
    and_fail.
    with_failure("exception from test")
  end
end
