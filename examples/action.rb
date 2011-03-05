$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'kintama'
require 'rubygems'
require 'kintama/mocha'

class TestMailer
  def send_email
  end
end

class Thing
  attr_reader :poke_count
  def initialize(mailer)
    @mailer = mailer
    @poke_count = 0
  end
  def poke
    @mailer.send_email
    @poke_count += 1
  end
  def poked?
    @poke_count > 0
  end
end

module Doing
  def doing(&block)
    @doing = block
  end

  def should_change(&block)
    doing_block = @doing
    should "change something" do
      previous_value = instance_eval(&block)
      instance_eval(&doing_block)
      subsequent_value = instance_eval(&block)
      assert subsequent_value != previous_value, "it didn't change"
    end
  end

  def expect(name, &block)
    doing_block = @doing
    test "expects #{name}" do
      instance_eval(&block)
      instance_eval(&doing_block)
    end
  end
end

Kintama.extend Doing

context "a thing" do
  setup do
    @mailer = TestMailer.new
    @thing = Thing.new(@mailer)
  end

  should "send an email when poked" do
    @mailer.expects(:send_email)
    @thing.poke
  end

  should "increase the poke count" do
    previous_poke_count = @thing.poke_count
    @thing.poke
    assert_equal previous_poke_count + 1, @thing.poke_count
  end

  should "be marked as poked" do
    @thing.poke
    assert @thing.poked?
  end
end

# vs

context "another thing" do

  setup do
    @mailer = TestMailer.new
    @thing = Thing.new(@mailer)
  end

  doing { @thing.poke }

  expect("an email to be sent") { @mailer.expects(:send_email)}

  should_change { @thing.poke_count }

  should("be marked as poked") { assert @thing.poked? }
end