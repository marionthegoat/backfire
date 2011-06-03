require_relative  'test_helper.rb'
require_relative '../lib/backfire'
class A4WorkspaceTest < Test::Unit::TestCase

  include Backfire::Model
  include Backfire::Exceptions

  def test_create
    c1 = ControlParam.new "rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, ControlParam::OPTION_YES
    w1 = Workspace.new(c1)
    assert_equal Workspace::STATE_NEW, w1.state
  end

  def test_protect
    assert_raise(BackfireException) { w2 = Workspace.new(nil) }
    assert_raise(BackfireException) { w2 = Workspace.new("parameters") }
  end

  def test_add
    c1 = ControlParam.new "rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, ControlParam::OPTION_YES
    w1 = Workspace.new(c1)
    f1=Fact.new("fact1","That's a fact")
    f2=Fact.new("fact2","You don't say?")
    w1.add_fact(f1,f2)
    assert_equal 2, w1.facts.size
    l1=FactList.new("List1")
    l1.add_member(f1)
    l2=FactList.new("List2")
    l2.add_member(f2)
    w1.add_fact(l1,l2)
    assert_equal 4, w1.facts.size
  end

  def test_add_query
     c1 = ControlParam.new "rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, ControlParam::OPTION_YES
     w1 = Workspace.new(c1)
     q1 = Query.new "test_query",Expression.parse("@fact1.value < @fact2.value || @fact1.value != @fact3.value"), "Factlist4"
     w1.add_query q1
     # see that query actually made it there
     assert_not_nil w1.queries[q1.name.to_sym]
     # see that expression facts got parsed out
     assert_not_nil w1.facts["fact1".to_sym]
     assert_not_nil w1.facts["fact2".to_sym]
     assert_not_nil w1.facts["fact3".to_sym]
     assert_not_nil w1.facts["Factlist4".to_sym]
     #see that determinant is correctly stitched into result fact
     l1=w1.facts["Factlist4".to_sym]
     assert_equal true, l1.determinants.include?(q1)
  end

end
