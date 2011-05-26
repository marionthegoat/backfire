module Backfire::Model
    class Query < Determinant
      attr_reader :fact_name
      def initialize(name, expression, fact)
        super(name,expression)
        @fact_name=fact
      end

    end
end
