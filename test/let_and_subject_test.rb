require 'test_helper'

class LetAndSubjectTest < Test::Unit::TestCase
  def test_let_should_return_value_of_block_when_called_in_tests
    x = context "" do
      let(:thing) { "a thing" }
      it("works") { assert_equal "a thing", thing }
    end
    x.run
    assert x.passed?
  end

  def test_let_should_return_the_same_instance_within_a_test
    x = context "" do
      let(:thing) { Object.new }
      it("works") { assert_equal thing.object_id, thing.object_id }
    end
    x.run
    assert x.passed?
  end

  def test_let_should_return_the_same_instance_within_a_test_and_its_setup
    x = context "" do
      let(:thing) { Object.new }
      setup { $object_id = thing.object_id }
      it("works") { assert $object_id && $object_id == thing.object_id }
    end
    x.run
    assert x.passed?
  end

  def test_let_should_return_different_instances_in_different_tests
    x = context "" do
      let(:thing) { Object.new }
      it("a") { $object_id = thing.object_id }
      it("b") { assert $object_id && $object_id != thing.object_id }
    end
    x.run
    assert x.passed?
  end

  def test_let_methods_should_be_callable_from_other_let_methods
    x = context "" do
      let(:alpha) { 123 }
      let(:beta) { alpha == 123 }
      it("a") { assert beta }
    end
    x.run
    assert x.passed?
  end

  def test_subject_should_work_just_like_lets
    x = context "" do
      subject { Object.new }
      it("a") { $object_id = subject.object_id }
      it("b") { assert $object_id && $object_id != subject.object_id }
    end
    x.run
    assert x.passed?
  end
end
