module Backfire
  module Model
    class Expression
      attr_accessor :facts, :factlists, :expression, :resolved_expr, :host

#      def initialize(expr, facts, factlists)
       def initialize(expr, facts)
        # convention : facts are just fact names in expressions.  The fact instances themselves are tracked at the assignment level
        @facts=facts # these values are full fact + method (thing which gets replaced at eval time)
#        @factlists=factlists
        @expression=expr
        @resolved_expr=nil
        @host=nil
      end

      def self.parse(expr)
        # find the fact names in the expression string
        # factoid = full fact / method spec
        # factname = fact reference proper
        # facts are lowercase, factlists are titlecase
        workstring=expr.clone
        _facts=[]
        _terms=workstring.split("@")
        _terms.each do |term|
          factoid = term.slice(/\w+/)
          _facts << factoid unless factoid.nil? || factoid.empty? || _facts.include?(factoid)
        end if workstring.include?("@")
 #       puts "Expresssion parse facts = #{_facts.inspect}"
        return Expression.new(expr, _facts)
      end

      def factlists
        factlist = []
        @facts.each do |fact|
          factlist << fact if Fact.is_list?(fact)
 #         puts "[Expression] factlist includes #{fact}" if Fact.is_list?(fact)
        end
        return factlist
      end

      def dirty
        @host.dirty unless @host.nil?
      end

      def list_facts(workspace,instr="")
        outstr = instr;
        @facts.each do |f|
          outstr +="#{f} = #{workspace.facts[f.to_sym].value} "
        end
        return outstr
      end


      # TODO : this really needs refactoring, should not reference workspace, etc
      def why (workspace, level)
        @facts.each do |f|
          workspace.facts[f.to_sym].why(workspace, level+1)
        end
      end

      def dump(level=0)
        output=[]
        indent=""
        for i in 1..level do
          indent +=". "
        end
        fstr=""
        @facts.each{ |f| fstr+=(" "+f)}
        outstr = "DUMP #{indent}Expression = #{@expression} facts=#{fstr}"
        output << outstr
        return output
      end

    end
  end
end