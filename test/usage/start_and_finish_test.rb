require "test_helper"

class StartAndFinishTest < KintamaIntegrationTest

  def setup
    $ran = 0
  end

  def test_should_call_any_on_start_block_when_running_a_context
    context "A context with a startup block" do
      on_start { $ran += 1 }
      should "have run the on_start block" do
        assert_equal 1, $ran
      end
    end.should_pass
  end

  def test_should_only_call_on_start_block_once_when_running_a_context
    context "A context with a startup block" do
      on_start { $ran += 1 }
      should "have run the on_start block" do
        assert_equal 1, $ran
      end
      should "not run that block again" do
        assert_equal 1, $ran
      end
    end.should_pass
  end

  def test_should_call_any_on_finish_block_when_running_a_context
    context "A context with a startup block" do
      should "have run the on_start block" do
      end
      on_finish { $ran += 1 }
    end.should_pass

    assert_equal 1, $ran
  end

  def test_should_only_call_on_finish_block_once_when_running_a_context
    context "A context with a startup block" do
      should "have run the on_start block" do
      end
      should "not run that block again" do
      end
      on_finish { $ran += 1 }
    end.should_pass

    assert_equal 1, $ran
  end

  def test_should_only_call_on_finish_block_after_all_tests
    context "A context with a startup block" do
      should "have run the on_start block" do
        assert_equal 0, $ran
      end
      should "not run that block again" do
        assert_equal 0, $ran
      end
      on_finish { $ran += 1 }
    end.should_pass
  end

  def test_should_be_able_to_use_rspec_like_aliases
    context "A context with a startup block" do
      before_all { $ran += 1 }
      should "have run the on_start block" do
        assert_equal 1, $ran
      end
      after_all { $ran += 1 }
    end.should_pass

    assert_equal 2, $ran
  end
end
