module Backfire::Model
    class Query < Determinant
      attr_reader :fact_name
      attr_accessor :prompt
      def initialize(name, expression, fact_name, prompt=false)
        super(name,expression,fact_name)
        @prompt=prompt
      end
      def is_prompt?
        return prompt
      end
    end
end
