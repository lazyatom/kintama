module Kintama
  module Runnable
    def self.included(base)
      base.class_eval { attr_accessor :name, :definition }
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
      definition ? definition.split(":").last.to_i : nil
    end
  end
end