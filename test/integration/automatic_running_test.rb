require 'test_helper'

class AutomaticRunningTest < KintamaIntegrationTest

  def test_should_be_able_to_run_kintama_tests_automatically_when_file_is_loaded
    test_with_content(%{
      context "given a thing" do
        should "work" do
          assert true
        end
      end
    }).run.should_have_passing_exit_status

    test_with_content(%{
      context "given a thing" do
        should "not work" do
          flunk
        end
      end
    }).run.should_have_failing_exit_status
  end
end
