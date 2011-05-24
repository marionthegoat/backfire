module Backfire
  module Model
    class Workspace

      include Backfire::Engine
      include Backfire::Exceptions

      STATE_NEW = "new"
      STATE_LIVE = "live"
      STATE_DEAD = "dead"

      attr_accessor :facts, :factlists, :determinants, :queries, :rules, :unconditional_rules, :engine, :state

      def initialize(params)
        raise BackfireException,"[Workspace] Error : Missing control parameters" if params.nil?
        raise BackfireException,"[Workspace] Error : Invalid control parameter object" if !(params.instance_of?(ControlParam))
        @factseq=0
        @facts=Hash.new
        @factlists=Hash.new
        @class_facts=Hash.new
        @determinants=Hash.new
        @rules=Hash.new
        @queries=Hash.new
        @dynamic_fact_values=Hash.new
        @engine=Backfire::Engine::BackfireEngine.new(self)
        @state=STATE_NEW
        @unconditional_rules=[]
        @control_params=params
      end

      def add_fact(*fact)
        return if fact.empty?
        first, *rest = fact
        @facts[first.name.to_sym]=first
        @state = STATE_LIVE if @state == STATE_DEAD
        if first.instance_of?(FactList)
           first.members.each do |f|
             add_fact(f)
           end
        end
        add_fact(*rest)
      end

#      def add_factlist(*list)
#        return if list.empty?
#        first, *rest = list
#        first.members.each do |f|
#          add_fact(f)
#        end
#        @factlists[first.name.to_sym]=first
#        @state = STATE_LIVE if @state == STATE_DEAD
#        add_factlist(*rest)
#      end

      def dynamic_fact_exists?(value)
        return !(@dynamic_fact_values[value].nil?)
      end

      def create_dynamic_fact(value, determinant)
#        puts "create_dynamic_fact value = #{value}"
        existing=@dynamic_fact_values[value]  #TODO: this seems questionable... May want to always generate new fact containers
        return existing unless existing.nil?
        @factseq+=1
        seq=@factseq.to_s
        if value.instance_of? Fact
          name = value.name + "_" + seq
          newval = value.value
        else
          name="dynamic" + "_" + seq
          newval = value
        end
        fact=Fact.new(name, newval, determinant.name)
        fact.add_determinant(determinant)
        add_fact(fact)
        @dynamic_fact_values[value]=fact
        return fact
      end

      def load_rules(rule_class, conditions=nil)
        # load directly from database
        conditions=:all if conditions.nil?
        rules=rule_class.constantize.send("find", conditions)
        rules.each do |rule|
          add_rule(rule.rule_instance)
        end
      end

      def load_queries(query_class, conditions=nil)
        #load directly from database
        conditions=:all if conditions.nil?
        queries=query_class.constantize.send("find", conditions)
        queries.each do |query|
          add_query(query.query_instance)
        end
      end

      def add_query(*queries)
        return if queries.empty?
        query, *rest = queries
        @state = STATE_LIVE if @state == STATE_DEAD
        @determinants[query.name.to_sym]=query
        @queries[query.name.to_sym]=query
        # we stitch facts and expressions together when expressions are introduced into the workspace
        query.expression.facts.each do |fact|
          @facts[fact.to_sym]=Fact.new(fact) unless @facts.has_key?(fact.to_sym)
          @facts[fact.to_sym].add_expression(query.expression)
        end
        unless query.fact_name.nil?
          result_fact=@facts[query.fact_name.to_sym]


          if Fact.is_atomic?(query.fact_name)
            result_fact=@facts[query.fact_name.to_sym]
            if result_fact.nil?
              #          puts "Adding atomic fact #{query.fact_name} to workspace for query #{query.name}"
              result_fact=Fact.new(query.fact_name)
              @facts[query.fact_name.to_sym]=result_fact
            end
          else
            result_fact=@facts[query.fact_name.to_sym]
            if result_fact.nil?
              #          puts "Adding list fact #{query.fact_name} to workspace for query #{query.name}"
              result_fact=FactList.new(query.fact_name)
              @facts[query.fact_name.to_sym]=result_fact
            end
          end
          # connect query and fact to each other
          #      puts "Connecting query #{query.name} to result fact #{result_fact.name} class #{result_fact.class.name}"
          query.fact=result_fact
          result_fact.add_determinant(query)
        end
        add_query(*rest)
      end

      def add_rule(*rules)
        return if rules.empty?
        rule, *rest = rules
        @state = STATE_LIVE if @state == STATE_DEAD
        @unconditional_rules << rule if rule.assertion.expression == Rule::UNCONDITIONAL
        @rules[rule.name.to_sym]=rule
        @determinants[rule.name.to_sym]=rule unless rule.fact_name.nil?
        # we stitch facts and expressions together when expressions are introduced into the workspace
        rule.assertion.facts.each do |fact|
# here we must sort out whether we have atomic fact or list
          @facts[fact.to_sym]=Fact.new(fact) if Fact.is_atomic?(fact) unless @facts.has_key?(fact.to_sym)
          @facts[fact.to_sym]=FactList.new(fact) unless Fact.is_atomic?(fact) || @facts.has_key?(fact.to_sym)
          @facts[fact.to_sym].add_expression(rule.assertion)
        end
#        rule.assertion.factlists.each do |factlist|
#          @factlists[factlist.to_sym]=FactList.new(factlist) unless @factlists.has_key?(factlist.to_sym)
#          @factlists[factlist.to_sym].add_expression(rule.assertion)
#        end
        # care must be taken to not treat predicate as determinant/query until rule proves to be true
        rule.predicate.facts.each do |fact|
          @facts[fact.to_sym]=Fact.new(fact) if Fact.is_atomic?(fact) unless @facts.has_key?(fact.to_sym)
          @facts[fact.to_sym]=FactList.new(fact) unless Fact.is_atomic?(fact) || @facts.has_key?(fact.to_sym)
          @facts[fact.to_sym].add_expression(rule.predicate)
        end
#        rule.predicate.factlists.each do |factlist|
#          @factlists[factlist.to_sym]=FactList.new(factlist) unless @factlists.has_key?(factlist.to_sym)
#          @factlists[factlist.to_sym].add_expression(rule.predicate)
#        end
        unless rule.fact_name.nil?
          if Fact.is_atomic?(rule.fact_name)
            result_fact=@facts[rule.fact_name.to_sym]
            if result_fact.nil?
#                        puts "Adding atomic fact #{rule.fact_name} to workspace for rule #{rule.name}"
              result_fact=Fact.new(rule.fact_name)
              @facts[rule.fact_name.to_sym]=result_fact
            end
          else
            result_fact=@facts[rule.fact_name.to_sym]
            if result_fact.nil?
 #                       puts "Adding list fact #{rule.fact_name} to workspace for rule #{rule.name}"
              result_fact=FactList.new(rule.fact_name)
              @facts[rule.fact_name.to_sym]=result_fact
            end
          end
          # connect rule and fact to each other
 #               puts "Connecting rule #{rule.name} to result fact #{result_fact.name} class #{result_fact.class.name}"
          rule.fact=result_fact
          result_fact.add_determinant(rule)
        end
        add_rule(*rest)
      end

      def why(fact)
        puts ""
        puts"WHY backtrace for #{fact} = #{@facts[fact.to_sym].value}  : "
        self.facts[fact.to_sym].determinants.each do |det|
          det.why(self,1) #unless det.state == Determinant::STATE_INDETERMINATE
        end
        puts ""
      end

      def dump
        output = []
        puts ""
        puts "Workspace Dump :"
        @determinants.each_value do |v|
          output.concat v.dump(1)
        end
        @facts.each_value do |v|
          output.concat v.dump
        end
        @factlists.each_value do |v|
          output.concat v.dump
        end
        puts ""
        return output
      end
    end
  end
end
