require 'test_helper'

class AliasesTest < KintamaIntegrationTest

  def test_provides_given_alias_for_context
    context "In a kintama test" do
      given "a context that is defined using the `given` method" do
        test "will be described using `given` in the output" do
          assert true
        end
      end
    end.
    should_output(%{
      In a kintama test
        given a context that is defined using the `given` method
          will be described using `given` in the output: .
    })
  end

  def test_provides_testcase_alias_for_context
    testcase "A context defined using `testcase`" do
      test "does not prefix anything to the context name" do
        assert true
      end
    end.
    should_output(%{
      A context defined using `testcase`
        does not prefix anything to the context name: .
    })
  end

  def test_provides_should_alias_for_test
    context "A context with a test defined using `should`" do
      should "output the test with `should` in the name" do
        assert true
      end
    end.
    should_output(%{
      A context with a test defined using `should`
        should output the test with `should` in the name: .
    })
  end

  def test_provides_it_alias_for_test
    context "A context with a test defined using `it`" do
      it "outputs the test with `it` in the name" do
        assert true
      end
    end.
    should_output(%{
      A context with a test defined using `it`
        it outputs the test with `it` in the name: .
    })
  end
end
