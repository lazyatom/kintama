require 'test_helper'

class AssertionsTest < Test::Unit::TestCase

  class PseudoTest
    include Kintama::Assertions
  end

  def setup
    @test = PseudoTest.new
  end

  def test_should_provide_assert
    assert_passed { @test.assert true }
    assert_failed("waaa") { @test.assert false, "waaa" }
  end

  def test_should_provide_flunk
    assert_failed(":(") { @test.flunk ":(" }
  end

  def test_should_provide_assert_equal
    assert_passed { @test.assert_equal 1, 1 }
    assert_failed("blurgh") { @test.assert_equal 1, 2, "blurgh" }
  end

  def test_should_provide_assert_not_equal
    assert_passed { @test.assert_not_equal 1, 2 }
    assert_failed("sadface") { @test.assert_not_equal 1, 1, "sadface" }
  end

  def test_should_provide_assert_nil
    assert_failed("bums") { @test.assert_nil Object.new, "bums" }
    assert_passed { @test.assert_nil nil }
  end

  def test_should_provide_assert_not_nil
    assert_passed { @test.assert_not_nil Object.new }
    assert_failed("fiddlesticks!") { @test.assert_not_nil nil, "fiddlesticks!" }
  end

  def test_should_provide_assert_kind_of
    assert_passed { @test.assert_kind_of Fixnum, 1 }
    assert_passed { @test.assert_kind_of Object, 1 }
    assert_passed { @test.assert_kind_of String, "hello" }
    assert_failed("pa!") { @test.assert_kind_of String, 1, "pa!" }
  end

  def test_should_provide_assert_nothing_raised
    assert_passed { @test.assert_nothing_raised { true } }
    assert_passed { @test.assert_nothing_raised { false } }
    assert_failed("ouch (oh no was raised)") { @test.assert_nothing_raised("ouch") { raise "oh no" } }
  end

  def test_should_provide_assert_raises
    assert_passed { @test.assert_raises { raise "urgh" } }
    assert_passed { @test.assert_raises(StandardError) { raise StandardError, "urgh" } }
    assert_failed("no way") { @test.assert_raises("no way") { false } }
    assert_failed { @test.assert_raises(RuntimeError) { raise StandardError, "urgh" } }
    assert_passed { @test.assert_raises("woah") { this_method_doesnt_exist } }
  end

  def test_should_provide_assert_match
    assert_passed { @test.assert_match /jam/, "bluejam" }
    assert_failed(%|expected "blah" to match /mm/|) { @test.assert_match /mm/, "blah" }
  end

  private

  def assert_passed
    yield
  end

  def assert_failed(message=nil)
    yield
    raise "assertion did not fail!" if failed
  rescue Kintama::TestFailure => e
    if message
      assert_equal message, e.message, "assertion failure message didn't match"
    end
  end
end