module Kintama
  module Context
    def setup # noop
    end

    def teardown # noop
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Create a new context. If this is called within a context, a new subcontext
      # will be created. Aliases are 'testcase' and 'describe'
      def context(name, parent=self, &block)
        c = Class.new(parent)
        c.send(:include, Kintama::Context)
        c.name = name.to_s
        c.class_eval(&block)
        c
      end
      alias_method :testcase, :context
      alias_method :describe, :context

      # Create a new context starting with "given "
      def given(name, parent=self, &block)
        context("given " + name, parent, &block)
      end

      def setup_blocks
        @setup_blocks ||= []
      end

      def teardown_blocks
        @teardown_blocks ||= []
      end

      # Define the setup for this context.
      # It will also be run for any subcontexts, before their own setup blocks
      def setup(&block)
        self.setup_blocks << block

        # redefine setup for the current set of blocks
        blocks = self.setup_blocks
        define_method(:setup) do
          super
          blocks.each { |b| instance_eval(&b) }
        end
      end

      # Define the teardown for this context.
      # It will also be run for any subcontexts, after their own teardown blocks
      def teardown(&block)
        self.teardown_blocks << block

        # redefine teardown for the current set of blocks
        blocks = self.teardown_blocks
        define_method(:teardown) do
          blocks.each { |b| instance_eval(&b) }
          super
        end
      end

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

      def inherited(child)
        children << child
      end

      def children
        @children ||= []
      end

      def tests
        children.select { |c| c.is_a_test? }.sort_by { |t| t.name }
      end

      def subcontexts
        children.select { |c| c.is_a_context? }.sort_by { |s| s.name }
      end

      # Returns true if this context has no known failed tests.
      def passed?
        failures.empty?
      end

      # Returns an array of tests in this and all subcontexts which failed in
      # the previous run
      def failures
        ran_tests.select { |t| !t.passed? } + subcontexts.map { |s| s.failures }.flatten
      end

      def pending
        tests.select { |t| t.pending? } + subcontexts.map { |s| s.pending }.flatten
      end

      def [](name)
        subcontexts.find { |s| s.name == name } || tests.find { |t| t.name == name }
      end

      def method_missing(name, *args, &block)
        if self[de_methodize(name)]
          self[de_methodize(name)]
        else
          begin
            super
          rescue NameError, NoMethodError => e
            if parent
              parent.send(name, *args, &block)
            else
              raise e
            end
          end
        end
      end

      def respond_to?(name)
        self[name] ||
        super ||
        (parent ? parent.respond_to?(name) : false)
      end

      # Runs all tests in this context and any subcontexts.
      # Returns true if all tests passed; otherwise false
      def run(runner=nil)
        @ran_tests = []
        runner.context_started(self) if runner
        tests.each { |t| instance = t.new; instance.run(runner); ran_tests << instance }
        subcontexts.each { |s| s.run(runner) }
        runner.context_finished(self) if runner
        passed?
      end

      private

      def de_methodize(name)
        name.to_s.gsub("_", " ")
      end

      def ran_tests
        @ran_tests || []
      end
    end
  end
end