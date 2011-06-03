puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  'test_helper.rb'
require_relative '../lib/backfire'

class A0ControlParamTest < Test::Unit::TestCase
  include Backfire::Model
  include Backfire::Exceptions

  def test_create
    @control_param = ControlParam.new "rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, ControlParam::OPTION_YES
    assert_not_nil @control_param
    assert_equal "rulebase_parameters", @control_param.name
    assert_equal ControlParam::BACKCHAIN_ONLY, @control_param.rulechain_option
    assert_equal 20, @control_param.runaway_limit
    assert_equal ControlParam::OPTION_YES, @control_param.log_output
  end

  def test_protection
    assert_raise (BackfireException) {ControlParam.new("rulebase_parameters", 'Z', 20, ControlParam::OPTION_YES)}
    assert_raise (BackfireException) {ControlParam.new("rulebase_parameters", ControlParam::BACKCHAIN_ONLY, 20, 'X')}
  end

end
