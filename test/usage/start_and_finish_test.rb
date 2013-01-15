require "test_helper"

class StartAndFinishTest < KintamaIntegrationTest

  def setup
    @order = sequence('order')
  end
  attr_reader :order

  def test_should_call_any_on_start_block_when_running_a_context
    spy = test_spy

    spy.expects(:in_startup).in_sequence(order)
    spy.expects(:in_test).in_sequence(order)

    context "A context with an `on_start` block" do
      on_start do
        spy.in_startup
      end

      should "have run the `on_start` block before a test" do
        spy.in_test
      end
    end
  end

  def test_should_only_call_on_start_block_once_when_running_a_context
    spy = test_spy

    spy.expects(:in_startup).once.in_sequence(order)
    spy.expects(:in_test).twice.in_sequence(order)

    context "A context with an `on_start` block" do
      on_start do
        spy.in_startup
      end

      should "have run the `on_start` block before a test" do
        spy.in_test
      end

      should "not run that block again before a second test" do
        spy.in_test
      end
    end
  end

  def test_should_call_on_start_block_in_nested_contexts
    spy = test_spy

    spy.expects(:outer_startup).once.in_sequence(order)
    spy.expects(:inner_startup).once.in_sequence(order)
    spy.expects(:in_test).twice.in_sequence(order)

    context "A context with an `on_start` block" do
      on_start do
        spy.outer_startup
      end

      context "and another `on_start` block in a nested context" do
        on_start do
          spy.inner_startup
        end

        should "have run both `on_start` blocks before running any tests" do
          spy.in_test
        end

        should "not run either `on_start` blocks before running subsequent tests" do
          spy.in_test
        end
      end
    end
  end

  def test_should_call_any_on_finish_block_when_running_a_context
    spy = test_spy

    spy.expects(:in_test).in_sequence(order)
    spy.expects(:in_finish).in_sequence(order)

    context "A context with an `on_finish` block" do
      should "not run the `on_finish` block before the test" do
        spy.in_test
      end

      on_finish do
        spy.in_finish
      end
    end
  end

  def test_should_only_call_on_finish_block_once_when_running_a_context
    spy = test_spy

    spy.expects(:in_test).twice.in_sequence(order)
    spy.expects(:in_finish).once.in_sequence(order)

    context "A context with an `on_finish` block" do
      should "not be run after every test" do
        spy.in_test
      end

      should "really not be run after every test" do
        spy.in_test
      end

      on_finish do
        spy.in_finish
      end
    end
  end

  def test_should_only_call_on_finish_block_after_all_tests
    spy = test_spy

    spy.expects(:in_test).times(3).in_sequence(order)
    spy.expects(:in_finish).once.in_sequence(order)

    context "A context with an `on_finish` block" do
      should "have not run the `on_finish` block before the first test" do
        spy.in_test
      end

      should "have not run the `on_finish` block before the second test" do
        spy.in_test
      end

      should "have not run the `on_finish` block before the third test" do
        spy.in_test
      end

      on_finish do
        spy.in_finish
      end
    end
  end

  def test_should_call_on_finish_block_in_nested_contexts
    spy = test_spy

    spy.expects(:in_test).twice.in_sequence(order)
    spy.expects(:inner_finish).once.in_sequence(order)
    spy.expects(:outer_finish).once.in_sequence(order)

    context "A context with an `on_finish` block" do
      context "and another `on_finish` block in a nested context" do
        should "not run either `on_finish` blocks before running the first test" do
          spy.in_test
        end

        should "not run either `on_start` blocks before running subsequent tests" do
          spy.in_test
        end

        on_finish do
          spy.inner_finish
        end
      end

      on_finish do
        spy.outer_finish
      end
    end
  end

  def test_should_not_rely_on_any_ordering_to_register_on_start_or_on_finish_blocks
    spy = test_spy

    spy.expects(:on_start).in_sequence(order)
    spy.expects(:in_test).in_sequence(order)
    spy.expects(:on_finish).in_sequence(order)

    context "A context with both an `on_start` and `on_finish` block" do
      on_finish do
        spy.on_finish
      end

      on_start do
        spy.on_start
      end

      should "allow those blocks to be defined in any order, but run them correctly" do
        spy.in_test
      end
    end
  end

  def test_should_be_able_to_use_rspec_like_aliases
    spy = test_spy

    spy.expects(:in_before_all).in_sequence(order)
    spy.expects(:in_test).in_sequence(order)
    spy.expects(:in_after_all).in_sequence(order)

    context "A context with `before_all` and `after_all` blocks" do
      before_all do
        spy.in_before_all
      end

      should "run exactly as on_start and `on_finish` blocks" do
        spy.in_test
      end

      after_all do
        spy.in_after_all
      end
    end
  end

  private

  def test_spy
    stub('test spy', poke: nil)
  end

end
