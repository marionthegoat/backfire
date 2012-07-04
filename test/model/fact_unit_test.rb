puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

describe Fact do

  it "supports these attributes" do
    f1 = Fact.new "test_fact", 18, "Initial Load"
    f1.must_respond_to :value
    f1.must_respond_to :name
    f1.must_respond_to :state
    f1.must_respond_to :expressions
    f1.must_respond_to :determinants
    f1.must_respond_to :origin
    f1.must_respond_to :immutable
    f1.must_respond_to :factlists
    f1.must_respond_to :workspace
  end

  it "acquires values from constructor" do
    f1 = Fact.new "test_fact", 18, "Initial Load"
    f1.name.must_equal "test_fact"
    f1.value.must_equal 18
    f1.origin.must_equal "Initial Load"
  end

  it "is always atomic" do
    f3 = Fact.new("some_name")
    f3.is_atomic?.must_equal true
  end

  it "rejects bad fact names" do
    -> {Fact.new("BadFactName", "some value", "bad_test")}.must_raise BackfireException
  end

  it "knows its indeterminate status" do
    f2 = Fact.new("i_dunno")
    f2.is_indeterminate?.must_equal true
    f2.value = "huh?"
    f2.is_indeterminate?.must_equal false
  end

  it "keeps track of its determinants" do
    f4 = Fact.new("tbd")
    f4.add_determinant(Query.new("find_it", "some value", "tbd"))
    f4.determinants.size.must_equal 1
  end

  it "keeps track of dependent expressions" do
    f6 = Fact.new("bounty")
    f6.add_expression(Expression.parse("@bounty == @lots_of_stuff"))
    f6.expressions.size.must_equal 1
  end


end