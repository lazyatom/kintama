$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = "true"
require 'kintama'

module Behaviour
  def should_do_stuff(other_name=nil, &block)
    should("do stuff #{other_name}".strip, &block)
  end
  def blah_blah(n)
    should_do_stuff(n) do
      flunk
    end
  end
end

context "given something" do
  extend Behaviour

  should "be red" do
    flunk
  end
  should "be green" do
    assert true
  end
  should "be yellow"
  
  context "and then" do
    should "this" do
    end

    should_do_stuff do
    end

    blah_blah "monkey"

    should "and that"
  end
end

# Kintama::Runner.new(*Kintama.default_context.subcontexts).run(Kintama::Reporter::Verbose.new, ["--line", "34"])
