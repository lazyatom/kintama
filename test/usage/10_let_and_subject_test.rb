require 'test_helper'

class LetAndSubjectTest < KintamaIntegrationTest

  def test_let_should_return_value_of_block_when_called_in_tests
    context "Defining a `let` attribute with a given name in a context" do
      let(:thing) do
        "a thing"
      end

      should "allow that attribute to be called as a method within tests" do
        assert_equal "a thing", thing
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_let_should_return_the_same_instance_within_a_test
    context "Defining a `let` attribute in a context" do
      let(:thing) do
        Object.new
      end

      should "memoize the returned object within a test" do
        instance_a = thing()
        instance_b = thing()
        assert_equal instance_a.object_id, instance_b.object_id
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_let_should_return_the_same_instance_within_a_test_and_its_setup
    context "Defining a `let` attribute in a context" do
      let(:thing) do
        Object.new
      end

      setup do
        $object_id = thing.object_id
      end

      should "memoize the returned object between setup and test" do
        assert $object_id && $object_id == thing.object_id
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_let_should_return_different_instances_in_different_tests
    context "Defining a `let` attribute in a context" do
      let(:thing) do
        Object.new
      end

      should "return a one instance in one test" do
        $object_id = thing.object_id
      end

      should "return some other instance in a different test" do
        assert $object_id && $object_id != thing.object_id
      end
    end.
    should_run_tests(2).
    and_pass
  end

  def test_let_methods_should_be_callable_from_other_let_methods
    context "Defining a `let` attribute in a context" do
      let(:alpha) do
        123
      end

      let(:beta) do
        alpha == 123
      end

      should "allow one `let` attribute to be referenced from another one" do
        assert beta
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_subject_should_work_just_like_lets
    context "Defining a `subject` attribute in a context" do
      subject do
        Object.new
      end

      should "return one instance in one test" do
        $object_id = subject.object_id
      end

      should "return a different instance in a different test" do
        assert $object_id && ($object_id != subject.object_id)
      end
    end.
    should_run_tests(2).
    and_pass
  end

  def test_should_use_a_single_instance_of_the_subject_within_a_test
    context "Given a context with a subject" do
      subject do
        Array.new
      end

      should "allow me to poke around with subject like it was a variable" do
        subject << 1
        assert_equal [1], subject
      end

      should "now be empty again because it's a new instance" do
        assert subject.empty?
      end
    end.
    should_run_tests(2).
    and_pass
  end
end
