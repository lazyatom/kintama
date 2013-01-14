require 'test_helper'

class InlineReporterTest < KintamaIntegrationTest
  report_with Kintama::Reporter::Inline

  def test_should_print_out_dots_when_a_test_passes
    context "given something" do
      should "pass" do
        assert true
      end
    end.
    should_output(%{
      .
    })
  end

  def test_should_print_out_many_dots_as_tests_run
    context "given something" do
      should "pass" do
        assert true
      end
      should "also pass" do
        assert true
      end
    end.
    should_output(%{
      ..
    })
  end

  def test_should_print_out_Fs_as_tests_fail
    context "given something" do
      should "fail" do
        flunk
      end
      should "pass" do
        assert true
      end
    end.
    should_output(%{
      F.
    })
  end

  def test_should_print_out_Ps_for_pending_tests
    context "given something" do
      should "not be implemented yet"
      should "pass" do
        assert true
      end
    end.
    should_output(%{
      P.
    })
  end
end
