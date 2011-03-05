$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'kintama'

class Thing
  def nature
    "thingish"
  end
end

context "A thing" do
  setup do
    @thing = Thing.new
  end
  should "act like a thing" do
    assert_equal "thingish", @thing.nature
  end
  context "with stuff" do
    should "also blah" do
    end
  end
end