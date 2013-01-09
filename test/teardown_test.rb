require 'test_helper'

class TeardownTest < Test::Unit::TestCase

  def test_should_run_teardown_after_the_test_finishes
    $called = false
    x = context "Given a teardown" do
      teardown do
        raise "Argh" unless @result == 123
        $called = true
      end
      should "run teardown after this test" do
        @result = 123
      end
    end
    x.run
    assert x.passed?
    assert $called
  end

  def test_should_run_all_teardowns_in_proximity_of_nesting_order_after_a_nested_test_finishes
    $called = false
    x = context "Given a teardown" do
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
    end
    x.run
    assert x.passed?
    assert $called
  end

  def test_should_run_teardown_defined_on_kintama_itself_after_other_teardowns
    ran = false
    Kintama.teardown do
      ran = true
      assert_equal 'blah', @thing
    end
    c = context "Given a context" do
      should "have run the setup defined in the default behaviour" do
        # nothing
      end
      teardown do
        @thing = 'blah'
      end
    end
    c.run
    assert c.passed?, "@thing was not redefined!"
    assert ran
  end

  def test_should_allow_multiple_teardowns_to_be_registered
    Kintama.teardown do
      $ran = 1
    end
    Kintama.teardown do
      $ran += 1
    end
    c = context "Given multiple setups" do
      should "run them all" do
        assert true
      end
    end
    c.run
    assert_equal 2, $ran, "both teardowns didn't run"
  end

  def test_should_run_teardowns_even_after_exceptions
    ran = false
    c = context "Given a test that fails" do
      should "still run teardown" do
        raise "argh"
      end
      teardown do
        ran = true
      end
    end
    c.run
    assert !c.passed?
    assert ran
  end

  def test_should_not_mask_exceptions_in_tests_with_ones_in_teardown
    c = context "Given a test that fails" do
      should "report this error" do
        raise "this"
      end
      teardown do
        raise "that"
      end
    end
    c.run
    assert !c.passed?
    assert_equal "this", c.failures.first.failure.to_s
  end
end
