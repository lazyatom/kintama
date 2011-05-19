module Kintama
  class Runnable
    class << self
      attr_accessor :name, :definition

      def to_s
        "<#{is_a_test? ? 'Test' : 'Context'}:#{name}>"
      end

      def is_a_test?
        ancestors.index(Kintama::Test) && 
        ancestors.index(Kintama::Test) < ancestors.index(Kintama::Context)
      end

      def is_a_context?
        !is_a_test?
      end

      def parent
        superclass.ancestors.include?(Kintama::Context) ? superclass : nil
      end

      # Returns the full name of this context, taking any parent contexts into account
      def full_name
        if @name
          [parent ? parent.full_name : nil, @name].compact.join(" ")
        else
          nil
        end
      end

      def line_defined
        definition ? definition.last : nil
      end
    end
  end
end