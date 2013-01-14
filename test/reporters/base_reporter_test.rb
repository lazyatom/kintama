require 'test_helper'

class BaseReporterTest < KintamaIntegrationTest
  report_with Kintama::Reporter::Base

  def test_assert_output_works
    assert_output("yes\n") do
      puts "yes"
    end
  end

  def test_should_print_summary_when_a_test_passes
    context "given something" do
      should "pass" do
        assert true
      end
    end.
    should_output("1 tests, 0 failures")
  end

  def test_should_print_out_summary_when_multiple_tests_pass
    context "given something" do
      should "pass" do
        assert true
      end
      should "also pass" do
        assert true
      end
    end.
    should_output("2 tests, 0 failures")
  end

  def test_should_print_out_summary_when_a_pending_test_exists
    context "given something" do
      should "pass" do
        assert true
      end
      should "not be implemented yet"
    end.
    should_output("2 tests, 0 failures, 1 pending")
  end

  def test_should_print_out_failure_details_if_tests_fail
    context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end.
    should_output(%{
      1) given something should fail:
        flunked
    })
  end

  def test_should_print_out_the_test_duration
    context "given something" do
      should "pass" do
        assert true
      end
    end.
    should_output(/^1 tests, 0 failures \(0\.\d+ seconds\)/)
  end

  def test_should_print_out_the_names_of_tests_that_fail
    context "given something" do
      should "fail" do
        flunk
      end
    end.
    should_output(%{
      1) given something should fail:
        flunked
    })
  end

  def test_should_include_line_in_test_of_error_in_failure_message
    context "given a test that fails" do
      should "report line of failing test" do
        $line = __LINE__; flunk
      end
    end.
    should_output(/#{Regexp.escape(File.expand_path(__FILE__))}:#{$line}/)
  end
end
