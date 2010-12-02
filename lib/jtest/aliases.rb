module JTest
  module Aliases
    module Context
      def context(name, parent=self, &block)
        JTest::Context.new(name, parent, &block)
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