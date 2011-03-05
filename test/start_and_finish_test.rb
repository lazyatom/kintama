require "test_helper"

class StartAndFinishTest < Test::Unit::TestCase
  
  def test_should_call_any_on_start_block_when_running_a_context
    $ran = 0
    c = context "A context with a startup block" do
      on_start { $ran += 1 }
      should "have run the on_start block" do
      end
    end
    c.run
    assert_equal 1, $ran
  end

  def test_should_only_call_on_start_block_once_when_running_a_context
    $ran = 0
    c = context "A context with a startup block" do
      on_start { $ran += 1 }
      should "have run the on_start block" do
      end
      should "not run that block again" do
      end
    end
    c.run
    assert_equal 1, $ran
  end

  def test_should_only_call_on_start_block_before_any_test
    $ran = 0
    c = context "A context with a startup block" do
      on_start { $ran += 1 }
      should "have run the on_start block" do
        assert_equal 1, $ran
      end
      should "not run that block again" do
        assert_equal 1, $ran
      end
    end
    c.run
    assert c.passed?
  end

  def test_should_call_any_on_finish_block_when_running_a_context
    $ran = 0
    c = context "A context with a startup block" do
      should "have run the on_start block" do
      end
      on_finish { $ran += 1 }
    end
    c.run
    assert_equal 1, $ran
  end

  def test_should_only_call_on_finish_block_once_when_running_a_context
    $ran = 0
    c = context "A context with a startup block" do
      should "have run the on_start block" do
      end
      should "not run that block again" do
      end
      on_finish { $ran += 1 }
    end
    c.run
    assert_equal 1, $ran
  end

  def test_should_only_call_on_finish_block_after_all_tests
    $ran = 0
    c = context "A context with a startup block" do
      should "have run the on_start block" do
        assert_equal 0, $ran
      end
      should "not run that block again" do
        assert_equal 0, $ran
      end
      on_finish { $ran += 1 }
    end
    c.run
    assert c.passed?
  end
end