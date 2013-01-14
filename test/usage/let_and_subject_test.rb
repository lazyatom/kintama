require 'test_helper'

class LetAndSubjectTest < KintamaIntegrationTest

  def test_let_should_return_value_of_block_when_called_in_tests
    context "" do
      let(:thing) { "a thing" }
      it("works") { assert_equal "a thing", thing }
    end.should_pass
  end

  def test_let_should_return_the_same_instance_within_a_test
    context "" do
      let(:thing) { Object.new }
      it("works") { assert_equal thing.object_id, thing.object_id }
    end.should_pass
  end

  def test_let_should_return_the_same_instance_within_a_test_and_its_setup
    context "" do
      let(:thing) { Object.new }
      setup { $object_id = thing.object_id }
      it("works") { assert $object_id && $object_id == thing.object_id }
    end.should_pass
  end

  def test_let_should_return_different_instances_in_different_tests
    context "" do
      let(:thing) { Object.new }
      it("a") { $object_id = thing.object_id }
      it("b") { assert $object_id && $object_id != thing.object_id }
    end.should_pass
  end

  def test_let_methods_should_be_callable_from_other_let_methods
    context "" do
      let(:alpha) { 123 }
      let(:beta) { alpha == 123 }
      it("a") { assert beta }
    end.should_pass
  end

  def test_subject_should_work_just_like_lets
    context "" do
      subject { Object.new }
      it("a") { $object_id = subject.object_id }
      it("b") { assert $object_id && $object_id != subject.object_id }
    end.should_pass
  end
end
