module Backfire
  module Model
    class Rule < Determinant
      # we use assertion in rule nomenclature to have less ambiguity.  We refer to expression when treating rule as a determinant
      attr_reader :predicate
# @param [String] name
# @param [String / Expression] assertion
# @param [String] fact_name
# @param [String / Expression] predicate
      def initialize (name, assertion, fact_name, predicate, workspace=nil)
        @predicate=predicate.instance_of?(Expression) ? predicate : Expression.parse(predicate)  # Expression class instance or string to be parsed as one
        super(name, assertion, fact_name, nil, workspace) # this happens after above so it can be added to workspace in super
      end
      def assertion
        self.expression
      end
    end
  end
end

