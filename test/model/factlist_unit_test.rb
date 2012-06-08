require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

describe FactList do
  f1 = FactList.new("My_things")

  it "supports these attributes" do
    f1.must_respond_to :members
  end

  it "can accept name from constructor" do
    f1.name.must_equal "My_things"
  end

  it "has a state which is initially indeterminate" do
    f1.state.must_equal FactList::STATE_INDETERMINATE
  end

  it "is not atomic" do
    f1.is_atomic?.must_equal false
  end

  it "is a (fact)list" do
    f1.is_list?.must_equal true
  end

  it "rejects bad names" do
    ->{ f2=FactList.new("bad_name")}.must_raise BackfireException
  end

  it "accepts new member facts" do
    f2=FactList.new("Good_list")
    f2.add_member(Fact.new("real_fact","really","unit test"))
    f2.members.size.must_equal 1
  end

  it "state becomes TRUE when populated" do
    f3=FactList.new("Wish_list")
    f3.add_member(Fact.new("real_fact","really","unit test"))
    f3.state.must_equal FactList::STATE_TRUE
  end

  it "Allows addition of simple values and wraps them as facts" do
    w1=Workspace.new(ControlParam.new("test"))
    f4=FactList.new("Trees",nil,"Premise",w1 )
    f4.add_member("Beech")
    f4.members.size.must_equal 1
    f4.add_member("Pine","Laurel")
    f4.members.size.must_equal 3
  end

  it "can accept array of facts in constructor" do
     f4=FactList.new("Trees",[Fact.new("f1","Beech"), Fact.new("f2","Pine"), Fact.new("f3","Willow")])
     f4.members.size.must_equal 3
  end

  it "accepts a list of values and wraps them as facts in the list as long as workspace is supplied in constructor" do
    w1=Workspace.new(ControlParam.new("test"))
    f4=FactList.new("Trees",["Larch","Alder","Fir","Oak"],"Initial Load",w1)
    f4.members.size.must_equal 4
    f4.members[0].must_be_instance_of Fact
  end

  it "can accept the fact values as an array" do
    w1=Workspace.new(ControlParam.new("test"))
    f4=FactList.new("Trees",["Larch","Alder","Fir","Oak","Oak"],"Initial Load",w1) # note duplicate value, it will be eliminate in list
    f4.fact_values.must_be_instance_of Array
    f4.fact_values.size.must_equal 4
    f4.fact_values.must_include "Alder"
  end

end