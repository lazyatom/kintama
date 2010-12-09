require 'test_helper'

class AliasesTest < Kintama_TestUnit_TestCase

  def test_should_provide_given_and_it_aliases_for_context_and_should
    x = context "In a world without hope" do
      given "a massive gun" do
        it "should work out well in the end" do
          assert true
        end
      end
    end
    x.run
    assert x.passed?
  end
end