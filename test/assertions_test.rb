require 'test/unit'
require 'jtest'

class AssertionsTest < Test::Unit::TestCase
  class PseudoTest
    include JTest::Assertions
  end

  def setup
    @test = PseudoTest.new
  end

  def test_should_provide_assert_nil
    assert_assertion_fails { @test.assert_nil Object.new }
    assert_assertion_passes { @test.assert_nil nil }
  end

  def test_should_provide_assert_not_nil
    assert_assertion_passes { @test.assert_not_nil Object.new }
    assert_assertion_fails { @test.assert_not_nil nil }
  end

  private

  def assert_assertion_passes
    yield
  end

  def assert_assertion_fails
    yield
    raise "assertion did not fail!"
  rescue JTest::TestFailure
    # nothing
  end
end