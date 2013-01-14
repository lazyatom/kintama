require 'test_helper'

class VerboseReporterTest < KintamaIntegrationTest
  report_with Kintama::Reporter::Verbose

  def test_should_print_out_test_names
    context "given something" do
      should "pass" do
        assert true
      end
      should "pass too" do
        assert true
      end
    end.
    should_output(%{
      given something
        should pass: .
        should pass too: .
    })
  end

  def test_should_print_out_Ps_beside_pending_test_names
    context "given something" do
      should "not be implemented"
      should "pass" do
        assert true
      end
    end.
    should_output(%{
      given something
        should not be implemented: P
        should pass: .
    })
  end

  def test_should_nest_printed_context_and_test_names
    context "given something" do
      should "pass" do
        assert true
      end
      context "and something else" do
        should "pass" do
          assert true
        end
      end
      context "and then this" do
        should "also pass" do
          assert true
        end
      end
    end.
    should_output(%{
      given something
        should pass: .
        and something else
          should pass: .
        and then this
          should also pass: .
    })
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_some_fail
    context "given something" do
      should "fail" do
        assert 1 == 2, "1 should equal 2"
      end
    end.
    should_output(%{
      given something should fail:
        1 should equal 2
    })
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_an_exception_occurs_in_a_test
    context "given something" do
      should "fail" do
        raise "unexpected issue!"
      end
    end.
    should_output(%{
      given something should fail:
        unexpected issue!
    })
  end

  def test_should_print_out_a_summary_of_the_failing_tests_if_a_nested_test_fails
    context "given something" do
      context "and something else" do
        should "fail" do
          assert 1 == 2, "1 should equal 2"
        end
      end
    end.
    should_output(%{
      given something and something else should fail:
        1 should equal 2
    })
  end

  def test_should_treat_a_context_as_transparent_if_it_has_no_name
    context "given something" do
      context do
        should "pass" do
          assert true
        end
      end
    end.
    should_output(%{
      given something
        should pass: .
    })
  end

  def test_should_print_out_test_names_in_colour_if_colour_is_set
    use_reporter Kintama::Reporter::Verbose.new(colour=true)

    context "given tests reported in colour" do
      should "show failures in red" do
        flunk
      end
      should "show passes in green" do
        assert true
      end
      should "show pending tests in yellow"
    end.
    should_output(%{
      given tests reported in colour
      \e\[31m  should show failures in red\e\[0m
      \e\[32m  should show passes in green\e\[0m
      \e\[33m  should show pending tests in yellow\e\[0m
    })
  end

  def test_should_print_appropriate_test_names_when_given_and_it_aliases_are_used
    context "In a world without hope" do
      given "a massive gun" do
        it "should work out well in the end" do
          assert true
        end
      end
    end.
    should_output(%{
      In a world without hope
        given a massive gun
          it should work out well in the end: .
    })
  end
end
