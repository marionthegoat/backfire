puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions
include Backfire::Engine

describe Workspace do

  it "supports these attributes" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    w1.must_respond_to :facts
    w1.must_respond_to :factlists
    w1.must_respond_to :determinants
    w1.must_respond_to :queries
    w1.must_respond_to :rules
    w1.must_respond_to :engine
    w1.must_respond_to :state
    w1.must_respond_to :control_params
    w1.must_respond_to :current_query
    w1.must_respond_to :errors
    w1.must_respond_to :is_new?
    w1.must_respond_to :is_dead?
    w1.must_respond_to :is_live?
    w1.must_respond_to :is_awaiting_input?
    w1.must_respond_to :goal_result
  end

  it "accepts control parameters in constructor" do
      c1 = ControlParam.new "rulebase_parameters"
      w1 = Workspace.new(c1)
      w1.state.must_equal Workspace::STATE_NEW
      w1.control_params.wont_be_nil
  end

  it "rejects invalid control parameter in constructor" do
    ->{ w2 = Workspace.new(nil) }.must_raise BackfireException
    ->{ w2 = Workspace.new("parameters") }.must_raise BackfireException
  end

  it "can add facts to itself" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    f1=Fact.new("fact1","That's a fact")
    f2=Fact.new("fact2","You don't say?")
    w1.add_fact(f1,f2)
    w1.facts.size.must_equal 2
    l1=FactList.new("List1")
    l1.add_member(f1)
    l2=FactList.new("List2")
    l2.add_member(f2)
    w1.add_fact(l1,l2)
    w1.facts.size.must_equal 4
  end

  it "can add queries to itself" do
      c1 = ControlParam.new "rulebase_parameters"
      w1 = Workspace.new(c1)
      q1 = Query.new "test_query",Expression.parse("@fact1.value < @fact2.value || @fact1.value != @fact3.value"), "Factlist4"
      w1.add_query q1
      # see that query actually made it there
      w1.queries[q1.name.to_sym].wont_be_nil
      # see that expression facts got parsed out
      w1.facts[:fact1].wont_be_nil
      w1.facts["fact2".to_sym].wont_be_nil
      w1.facts["fact3".to_sym].wont_be_nil
      w1.facts["Factlist4".to_sym].wont_be_nil
      #see that determinant is correctly stitched into result fact
      l1=w1.facts["Factlist4".to_sym]
      l1.determinants.must_include q1
  end

  it "can add rules to itself" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    r1 = Rule.new("broke","@wallet.value < 1", "status", "@broke = true")
    w1.add_rule(r1)
    w1.facts[:wallet].wont_be_nil
  end

  it "has an inference engine built-in" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    w1.engine.wont_be_nil
    w1.engine.must_be_instance_of BackfireEngine
  end


end