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

    module Test
      # Define a test to run in this context.
      def test(name, &block)
        c = Class.new(self)
        c.send(:include, Kintama::Test)
        c.name = name
        c.block = block if block_given?
      end

      # Define a test to run in this context. The test name will start with "should "
      def should(name, &block)
        test("should " + name, &block)
      end

      # Define a test to run in this context. The test name will start with "it "
      def it(name, &block)
        test("it " + name, &block)
      end
    end
  end
end