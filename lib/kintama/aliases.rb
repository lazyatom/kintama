module Kintama
  module Aliases
    module Context
      def context(name, parent=self, &block)
        c = Class.new(parent)
        c.send(:include, Kintama::Context)
        c.name = name
        c.class_eval(&block)
        c
      end

      def given(name, parent=self, &block)
        context("given " + name, parent, &block)
      end

      def describe(thing, parent=self, &block)
        context(thing.to_s, parent, &block)
      end

      def testcase(name, parent=self, &block)
        context(name, parent, &block)
      end
    end
  end
end