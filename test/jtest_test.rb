require 'test/unit'

class Context
  def initialize(&block)
    @block = block
  end
  def run
    instance_eval(&@block)
  end
  def should(name, &block)
    instance_eval(&block)
  end
  def assert(expression)
    @passed = expression
  end
  def passed?
    @passed
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

  def test_should_fail_when_all_tests_fail
    x = context "Given something" do
      should "work" do
        assert false
      end
    end
    x.run
    assert !x.passed?
  end

  private

  def context(name, &block)
    Context.new(&block)
  end
end