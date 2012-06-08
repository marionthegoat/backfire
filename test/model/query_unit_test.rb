puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions

#
# Note that we don't have any tests for Determinant itself, as it's an abstract class not intended to be used directly.
# We use Query to test all the basic capabilities of Determinant
#
describe Query do

  q1 = Query.new("PlazJohnson", "saxophone","instrument")

  it "supports these attributes" do
    q1.must_respond_to :name
    q1.must_respond_to :expression
    q1.must_respond_to :fact
    q1.must_respond_to :fact_name
    q1.must_respond_to :state
    q1.must_respond_to :workspace
  end

  it "acquires target fact from constructor" do
    q1.fact_name.must_equal "instrument"
  end

  it "aquires query name from constructor" do
    q1.name.must_equal "PlazJohnson"
  end

  it "can parse expression from string supplied in constructor"  do
    q1.expression.must_be_instance_of Expression
  end

end