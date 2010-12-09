require 'test_helper'

class InlineRunnerTest < Kintama_TestUnit_TestCase
  def test_should_print_out_dots_when_a_test_passes
    c = context "given something" do
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    assert_output(/^\.\n/) do
      r.run
    end
  end

  def test_should_print_out_many_dots_as_tests_run
    c = context "given something" do
      should "pass" do
        assert true
      end
      should "also pass" do
        assert true
      end
    end
    r = runner(c)
    assert_output(/^\.\.\n/) do
      r.run
    end
  end

  def test_should_print_out_Fs_as_tests_fail
    c = context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    assert_output(/^F\./) do
      r.run
    end
  end

  def test_should_print_out_Ps_for_pending_tests
    c = context "given something" do
      should "not be implemented yet"
      should "pass" do
        assert true
      end
    end
    r = runner(c)
    assert_output(/^P\./) do
      r.run
    end
  end

  private

  def runner(*args)
    Kintama::Runner::Inline.new(*args)
  end
end