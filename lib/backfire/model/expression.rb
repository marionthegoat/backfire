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
        #    puts "Expression.parse expr = #{expr}"
        workstring=expr.clone
        _facts=[]
        _factlists=[]
        done=false
        while not done do
          factref = workstring.slice(/[@].[\w@]+/) #isolates fact
          if factref.nil?
            done=true;
          else
            # factoid = full fact / method spec
            # factname = fact reference proper
            factoid = factref.slice(/\w+/) # removes ampersand
            workstring.sub!(factref,"") # lop off what we just parsed
            #       puts "Expression.parse factoid = #{factoid} is_list = #{Fact.is_list?(factoid)}"
            #facts are lowercase, factlists are titlecase
            _facts << factoid unless _facts.include?(factoid) #if Fact.is_atomic?(factoid)
 #           _factlists << factoid unless _factlists.include?(factoid) if Fact.is_list?(factoid)
            done = true if workstring.nil? || workstring.length == 0
          end
        end
        #   puts("Expression factlists = #{_factlists}")
 #       return Expression.new(expr, _facts, _factlists)
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

      def dump(level)
        output=[]
        indent=""
        for i in 1..level do
          indent +=". "
        end
        fstr=""
        flstr=""
        @facts.each{ |f| fstr+=(" "+f)}
#        @factlists.each{ |f| flstr+=(" "+f)}
        outstr = "DUMP #{indent}Expression = #{@expression} facts=#{fstr} factlists=#{flstr} }"
        output << outstr
        return output
      end

    end
  end
end