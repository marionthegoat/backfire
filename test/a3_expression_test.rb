require File.dirname(__FILE__) + '/test_helper.rb'
require 'backfire'

class A3ExpressionTest < Test::Unit::TestCase

include Backfire::Model

  def test_expression_literal
    expr1=Expression.parse("15")
    assert_equal 0, expr1.facts.length
    assert_equal "15", expr1.expression
  end
  
  def test_expression_facts
    expr2=Expression.parse("@fact_1.value < @fact2.value || @fact_1.value != @fact3.value")
    assert_equal 3, expr2.facts.length
    assert_equal "fact_1", expr2.facts[0]
    assert_equal "fact2", expr2.facts[1]
    assert_equal "fact3", expr2.facts[2]
    assert_equal "@fact_1.value < @fact2.value || @fact_1.value != @fact3.value", expr2.expression
  end

  def test_expression_factlists
    expr4=Expression.parse("@Birds.value.name < @fact2.value || @Acorns.value != @fact3.value")
    assert_equal 2, expr4.factlists.length
    assert_equal "Birds", expr4.factlists[0]
    assert_equal "Acorns", expr4.factlists[1]
  end

  def test_expression_association
    expr3=Expression.parse("@factrec.value.items.unit_of_measure")
    assert_equal 1, expr3.facts.length
    assert_equal "factrec", expr3.facts[0]
    assert_equal "@factrec.value.items.unit_of_measure", expr3.expression
  end

end
