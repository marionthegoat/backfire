module Backfire
  module Model
    # Determinant
    # This constitutes a sort of abstract root class containing the common elements for query and rule
    #
    class Determinant
      STATE_INDETERMINATE = "indeterminate"
      STATE_TRUE = "true"
      STATE_FALSE = "false"

      attr_accessor :name, :expression, :fact,  :state

      def initialize(name, expression,  fact=nil)
        @name=name  # hash key in workspace
        @expression=expression  # Expression class instance
        @expression.host = self
        @fact=fact  # Fact or factlist class instance
        @state=STATE_INDETERMINATE
      end

      def why(workspace,level)
        indent=""
        for i in 1..level do
          indent +=". "
        end
        because="WHY : #{indent} #{self.class.name} #{self.name}".ljust(40)+" state= #{self.state}".ljust(15)+
          " resolved to : #{@expression.resolved_expr}".ljust(40)+
          " premise facts :"
        @expression.facts.each do |f|
          because +="#{f} = #{workspace.facts[f.to_sym].value} "
        end
        puts because
        @expression.facts.each do |f|
          workspace.facts[f.to_sym].why(workspace, level+1)
        end
      end
  
      def expression_has_factlist?
        return @expression.factlists.length > 0
      end
  
      def receiver_is_factlist?
        return true if fact.instance_of? FactList
        return false
      end

      def dirty
        #    puts "#{self.class.name} #{self.name} is now DIRTY"
        self.state = STATE_INDETERMINATE
      end

      def dump(level)
        output=[]
        indent=""
        for i in 1..level do
          indent +=". "
        end
        outstr = "DUMP #{indent}Determinant #{self.class.name} name: #{@name} fact: #{@fact.name} value : #{@fact.value}  state : #{@state}" unless @fact.is_list?
        puts outstr
        output << outstr
        outstr =  "DUMP #{indent}Determinant #{self.class.name} name: #{@name} fact: #{@fact.name} value : (FactList)  state : #{@state}" if @fact.is_list?
        puts outstr
        output << outstr
        output.concat @expression.dump(level+1)
        return output
      end

    end
  end
end