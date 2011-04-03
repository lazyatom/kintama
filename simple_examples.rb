$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'kintama'

given "some stuff" do
  should "work" do
    assert true
  end

  should "also work" do
    assert true
  end

  should "not work" do
    # assert true
    flunk
  end

  should "be pending"

  context "and this thing" do
    should "not work" do
      assert false, "something bad happened"
    end
  end
end