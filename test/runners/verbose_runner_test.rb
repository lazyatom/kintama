require 'test_helper'

class VerboseRunnerTest < Kintama_TestUnit_TestCase
  def test_should_print_out_test_names
    c = context "given something" do
      should "also pass" do
        assert true
      end
      should "pass" do
        assert true
      end
    end
    assert_output(/^given something\n  should also pass: \.\n  should pass: \./) do
      runner(c).run(false)
    end
  end

  def test_should_print_out_Ps_beside_pending_test_names
    c = context "given something" do
      should "not be implemented"
      should "pass" do
        assert true
      end
    end
    assert_output(/^given something\n  should not be implemented: P\n  should pass: \./) do
      runner(c).run(false)
    end
  end

  def test_should_nest_printed_context_and_test_names
    c = context "given something" do
      should "pass" do
        assert true
      end
      context "and then this" do
        should "also pass" do
          assert true
        end
      end
      context "and something else" do
        should "pass" do
          assert true
        end
      end
    end
    assert_output(/^given something\n  should pass: \.\n  and something else\n    should pass: \.\n  and then this\n    should also pass: \./) do
      runner(c).run(false)
    end
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_some_fail
    c = context "given something" do
      should "fail" do
        assert 1 == 2, "1 should equal 2"
      end
    end
    assert_output(/given something should fail:\n  1 should equal 2/) { runner(c).run(false) }
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_an_exception_occurs_in_a_test
    c = context "given something" do
      should "fail" do
        raise "unexpected issue!"
      end
    end
    assert_output(/given something should fail:\n  unexpected issue!/) { runner(c).run(false) }
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_a_nested_test_fails
    c = context "given something" do
      context "and something else" do
        should "fail" do
          assert 1 == 2, "1 should equal 2"
        end
      end
    end
    assert_output(/given something and something else should fail:\n  1 should equal 2/) { runner(c).run(false) }
  end

  def test_should_nest_verbose_output_properly_when_running_tests_from_several_contexts
    c1 = context "given something" do
      should "pass" do
        assert true
      end
    end
    c2 = context "given another thing" do
      should "also pass" do
        assert true
      end
    end
    assert_output(/^given something\n  should pass: \.\n\ngiven another thing\n  should also pass: \./) do
      runner(c1, c2).run(false)
    end
  end

  def test_should_print_out_test_names_in_colour_if_colour_is_set
    c = context "given something" do
      should "be red" do
        flunk
      end
      should "be green" do
        assert true
      end
      should "be yellow"
    end
    assert_output(/^given something\n\e\[32m  should be green\e\[0m\n\e\[31m  should be red\e\[0m\n\e\[33m  should be yellow\e\[0m/) do
      runner(c).run(colour=true)
    end
  end

  def test_should_print_appropriate_test_names_when_given_and_it_aliases_are_used
    c = context "In a world without hope" do
      given "a massive gun" do
        it "should work out well in the end" do
          assert true
        end
      end
    end
    assert_output(/^In a world without hope\n  given a massive gun\n    it should work out well in the end: \./) do
      runner(c).run(false)
    end
  end

  private

  def runner(*args)
    Kintama::Runner::Verbose.new(*args)
  end
end