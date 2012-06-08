puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions

describe Rule do
  r1 = Rule.new("broke","@wallet.value < 1", "status", "BROKE")
  r2 = Rule.new("rich",Expression.parse("@bank_account > 1000000"),"status",Expression.parse("RICH"))
  
  it "supports these attributes" do
    r1.must_respond_to :name
    r1.must_respond_to :expression
    r1.must_respond_to :fact
    r1.must_respond_to :fact_name
    r1.must_respond_to :state
    r1.must_respond_to :workspace
    r1.must_respond_to :predicate
  end
  
  it "acquires target fact from constructor" do
    r1.fact_name.must_equal "status"
  end

  it "acquires rule name from constructor" do
    r1.name.must_equal "broke"
  end

  it "can parse assertion expression from string supplied in constructor"  do
    r1.assertion.must_be_instance_of Expression
  end

  it "can parse predicate expression from string supplied in constructor" do
    r1.predicate.must_be_instance_of Expression
  end

  it "can accept expression object as assertion or predicate" do
    r2.assertion.must_be_instance_of Expression
    r2.predicate.must_be_instance_of Expression
  end

end