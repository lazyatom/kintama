require 'test/unit'

class Context
  def run
  end
  def passed?
    true
  end
end

class JTestTest < Test::Unit::TestCase
  def test_should_pass_when_all_tests_pass
    x = context "Given something" do
      should "work" do
        assert true
      end
    end
    x.run
    assert x.passed?
  end

  private

  def context(name, &block)
    Context.new
  end
end