require 'test_helper'

class TeardownTest < KintamaIntegrationTest

  def setup
    super
    @order = sequence('teardown order')
  end
  attr_reader :order

  def test_should_run_teardown_after_the_test_finishes
    spy = teardown_spy
    spy.expects(:in_test).once.in_sequence(order)
    spy.expects(:tore_down).once.in_sequence(order)

    context "Given a context with a teardown block" do
      teardown do
        spy.tore_down
      end

      should "run teardown after the test runs" do
        spy.in_test
      end
    end
  end

  def test_should_run_all_teardowns_in_proximity_of_nesting_order_after_a_nested_test_finishes
    spy = teardown_spy
    spy.expects(:tore_down).with(:inner).in_sequence(order)
    spy.expects(:tore_down).with(:outer).in_sequence(order)

    context "Given a context with a teardown block" do
      teardown do
        spy.tore_down(:outer)
      end

      context "with a subcontext with another teardown block" do
        teardown do
          spy.tore_down(:inner)
        end

        should "run the inner and then outer teardowns after this test" do
        end
      end
    end
  end

  def test_should_run_teardown_defined_on_kintama_itself_after_other_teardowns
    spy = teardown_spy
    spy.expects(:tore_down).with(:context_teardown).in_sequence(order)
    spy.expects(:tore_down).with(:kintama_global_teardown).in_sequence(order)

    Kintama.teardown do
      spy.tore_down(:kintama_global_teardown)
    end

    context "Given a context with a teardown block" do
      should "run the context teardown, and then the kintama global teardown" do
      end

      teardown do
        spy.tore_down(:context_teardown)
      end
    end
  end

  def test_should_allow_multiple_teardowns_to_be_registered
    spy = teardown_spy
    spy.expects(:tore_down).with(:first_teardown).in_sequence(order)
    spy.expects(:tore_down).with(:second_teardown).in_sequence(order)

    context "Given a context with multiple teardown blocks" do
      should "run them all in the order they appear" do
        assert true
      end

      teardown do
        spy.tore_down(:first_teardown)
      end

      teardown do
        spy.tore_down(:second_teardown)
      end
    end
  end

  def test_should_run_teardowns_even_after_exceptions_in_tests
    spy = teardown_spy
    spy.expects(:tore_down)

    context "Given a test that fails" do
      should "still run teardown" do
        raise "BOOM"
      end

      teardown do
        spy.tore_down
      end
    end
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
    should_fail.
    with_failure("exception from test")
  end

  private

  def teardown_spy
    stub('teardown spy', tore_down: nil)
  end
end
