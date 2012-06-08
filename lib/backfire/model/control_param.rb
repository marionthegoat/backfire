module Backfire
  module Model
    class ControlParam

      include Exceptions

      BACKCHAIN_ONLY = "B"
      LIMITED_FORWARD = "L"
      FORWARD = "F"
      OPTION_YES = "Y"
      OPTION_NO = "N"
      RULECHAIN_OPTIONS = [BACKCHAIN_ONLY, LIMITED_FORWARD, FORWARD]
      OPTIONS = [OPTION_YES, OPTION_NO]

      attr_reader :name, :rulechain_option, :runaway_limit, :log_output

      def initialize(name, rulechain_option = BACKCHAIN_ONLY, runaway_limit = 20, log_output = OPTION_YES)
        raise BackfireException,"[ControlParam] Error : Invalid rulechain option #{rulechain_option}" if !(RULECHAIN_OPTIONS.include? rulechain_option)
        raise BackfireException,"[ControlParam] Error : Invalid logging option #{log_output}" if !(OPTIONS.include? log_output)
        raise BackfireException,"[ControlParam] Error : Invalid runaway limit #{runaway_limit}" if (runaway_limit <= 1)
        @name=name
        @rulechain_option=rulechain_option
        @runaway_limit=runaway_limit
        @log_output=log_output
      end
    end
  end
end