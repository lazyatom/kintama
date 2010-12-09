module Kintama
  class TestEnvironment
    include Assertions

    def initialize(context)
      @__context = context
    end

    def method_missing(*args, &block)
      @__context.send(*args, &block)
    end

    def respond_to?(name)
      @__context.respond_to?(name)
    end
  end
end