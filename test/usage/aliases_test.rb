require 'test_helper'

class AliasesTest < KintamaIntegrationTest

  def test_should_provide_given_and_it_aliases_for_context_and_should
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
    }).
    and_pass
  end

  def test_should_provide_testcase_alias_for_context
    testcase "In a world without hope" do
      should "work out well in the end" do
        assert true
      end
    end.
    should_output(%{
      In a world without hope
        should work out well in the end: .
    }).
    and_pass
  end
end
