module Backfire
  module Model
    class Rule < Determinant
      UNCONDITIONAL = "true"
      # we use assertion in rule nomenclature to have less ambiguity.  We refer to expression when treating rule as a determinant
      attr_accessor :fact_name
      attr_reader :predicate
      def initialize (name, assertion, fact, predicate)
        super(name,assertion)
        @fact_name=fact
        @predicate=predicate
      end
      def assertion
        self.expression
      end
    end
  end
end

