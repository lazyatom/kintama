require 'test_helper'

class PendingTestsTest < KintamaIntegrationTest

  def test_should_pass_any_pending_tests
    context "Given a context with an unimplemented test" do
      should "indicate that the test is not implemented" # NOTE - no test body
    end.
    should_output(%{
      Given a context with an unimplemented test
        should indicate that the test is not implemented: P
    }).
    and_pass
  end

end
