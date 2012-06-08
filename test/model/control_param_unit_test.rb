puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions

describe ControlParam do

  control_param = ControlParam.new "rulebase_parameters"

  it "supports these attributes" do
    control_param.must_respond_to :name
    control_param.must_respond_to :rulechain_option
    control_param.must_respond_to :runaway_limit
    control_param.must_respond_to :log_output
  end

  it "can be created" do
    control_param.must_be_instance_of ControlParam
  end

  it "can be assigned a name in constructor" do
    control_param.name.must_equal "rulebase_parameters"
  end

  it "has option for rulechain behavior" do
    control_param.rulechain_option.must_equal ControlParam::BACKCHAIN_ONLY
  end

  it "accepts a runaway limit" do
    control_param.runaway_limit.must_equal 20
  end

  it "has output logging option" do
    control_param.log_output.must_equal ControlParam::OPTION_YES
  end

  it "rejects invalid backchain option" do
    -> {ControlParam.new("rulebase_parameters", ControlParam::OPTION_YES)}.must_raise BackfireException
  end

  it "rejects invalid runaway limit" do
    -> {ControlParam.new("rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 1)}.must_raise BackfireException
  end

  it "rejects invalid logging option" do
    -> {ControlParam.new("rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, 'X')}.must_raise BackfireException
  end

end

