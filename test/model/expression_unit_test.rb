puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions

describe Expression do
# create some sample instances to test using parser
  expr1=Expression.parse("15")
  expr2=Expression.parse("@fact1.value < @fact2.value || @fact1.value != @fact3.value")
  expr3=Expression.parse("@factrec.value.items.unit_of_measure")
  expr4=Expression.parse("@Birds.value.name < @fact2.value || @Acorns.value != @fact3.value") # This uses factlists

  it "can parse a literal expression" do
    expr1.facts.size.must_equal 0
    expr1.expression.must_equal "15"
  end

  it "can parse a simple expression containing atomic fact" do
    expr = Expression.parse("@c.value ** 2")
    expr.facts.size.must_equal 1
  end

  it "can parse a complex expression containing atomic facts" do
    expr2.facts.size.must_equal 3
    expr2.facts[0].must_equal "fact1"
    expr2.facts[1].must_equal "fact2"
    expr2.facts[2].must_equal "fact3"
    expr2.expression.must_equal "@fact1.value < @fact2.value || @fact1.value != @fact3.value"
  end

  it "can parse an expression referencing a method" do
    expr3.facts.size.must_equal 1
    expr3.facts[0].must_equal "factrec"
    expr3.expression.must_equal "@factrec.value.items.unit_of_measure"
  end

  it "can parse a complex expression containing factlists" do
    expr4.facts.size.must_equal 4
    expr4.facts.must_include "Birds"
    expr4.facts.must_include "Acorns"
  end

  it "can dump its content" do
    expr1.dump[0].must_equal "DUMP Expression = 15 facts="
    expr2.dump[0].must_equal "DUMP Expression = @fact1.value < @fact2.value || @fact1.value != @fact3.value facts= fact1 fact2 fact3"
    expr3.dump[0].must_equal "DUMP Expression = @factrec.value.items.unit_of_measure facts= factrec"
    expr4.dump[0].must_equal "DUMP Expression = @Birds.value.name < @fact2.value || @Acorns.value != @fact3.value facts= Birds fact2 Acorns fact3"
   end

end