module Backfire::Model
    class Query < Determinant
      attr_reader :fact_name
      def initialize(name, expression, fact_name, workspace=nil)
        super(name,expression,fact_name, nil, workspace )
      end

    end
end
