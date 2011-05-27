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

      def is_dead?
        return @state == STATE_DEAD
      end

      def is_live?
        return @state == STATE_LIVE
      end

      def is_new?
        return @state == STATE_NEW
      end

      def add_fact(*fact)
        return if fact.empty?
        first, *rest = fact
        first.workspace = self
        @facts[first.name.to_sym]=first
        @state = STATE_LIVE if @state == STATE_DEAD
        first.members.each {|f| add_fact(f) } if first.instance_of?(FactList)
        add_fact(*rest)
      end

      def get_fact(name)
        return @facts[name.to_sym]
      end

      def add_determinant(determinant)
         determinant.workspace = self
         @determinants[determinant.name.to_sym]=determinant
         @queries[determinant.name.to_sym]=determinant if determinant.instance_of? Query
         @rules[determinant.name.to_sym]=determinant if determinant.instance_of? Rule
         @state = STATE_LIVE if @state == STATE_DEAD
      end

      # this factors the difference between fact and factlist
      def get_factoid(name)
          return get_fact(name) unless get_fact(name).nil?
          factoid=Fact.new(name) if Fact.is_atomic?(name)
          factoid=FactList.new(name) unless Fact.is_atomic?(name)
          add_fact(factoid)
          return factoid
      end


      def dynamic_fact_exists?(value)
        return !(@dynamic_fact_values[value].nil?)
      end

      def gen_dynamic_fact_name(value)
        @factseq+=1
        seq=@factseq.to_s
        return value.name + "_" + seq if value.instance_of? Fact
        return name="dynamic" + "_" + seq
      end

      def scrub_fact_value(value)
        return value.value if value.instance_of? Fact
        return value
      end

      def create_dynamic_fact(value, determinant)
#        puts "create_dynamic_fact value = #{value}"
        existing=@dynamic_fact_values[value]  #TODO: this seems questionable... May want to always generate new fact containers
        return existing unless existing.nil?
        name = gen_dynamic_fact_name(value)
        newval = scrub_fact_value(value)
        fact=Fact.new(name, newval, determinant.name)
        fact.add_determinant(determinant)
        add_fact(fact)
        @dynamic_fact_values[value]=fact
        return fact
      end

      def create_result_fact(name, determinant)
        return nil if name.nil?
        result_fact=get_factoid(name)
        result_fact.add_determinant(determinant)
        determinant.fact=result_fact
      end

 # we stitch facts and expressions together when expressions are introduced into the workspace
      def gen_facts_from_expression(expression)
          expression.facts.each do |fact|
            fact_instance = get_factoid(fact)
            fact_instance.add_expression(expression)
          end
      end


      def load_rules(rule_class, conditions=nil)
        # load directly from database
        conditions=:all if conditions.nil?
        instances=rule_class.constantize.send("find", conditions)
        instances.each do |rule|
          add_rule(rule.rule_instance)
        end
      end

      def load_queries(query_class, conditions=nil)
        #load directly from database
        conditions=:all if conditions.nil?
        instances=query_class.constantize.send("find", conditions)
        instances.each do |query|
          add_query(query.query_instance)
        end
      end

      def add_query(*queries)
        return if queries.empty?
        query, *rest = queries
        add_determinant(query)
        gen_facts_from_expression(query.expression)
        create_result_fact(query.fact_name, query)
        add_query(*rest)
      end

      def add_rule(*rules)
        return if rules.empty?
        rule, *rest = rules
        @unconditional_rules << rule if rule.assertion.expression == Rule::UNCONDITIONAL
        add_determinant(rule)
        gen_facts_from_expression(rule.assertion)
        gen_facts_from_expression(rule.predicate)
        create_result_fact(rule.fact_name, rule)
        add_rule(*rest)
      end

      def why(fact)
        puts ""
        puts"WHY backtrace for #{fact} = #{@facts[fact.to_sym].value}  : "
        self.facts[fact.to_sym].determinants.each do |det|
          det.why(1) 
        end
        puts ""
      end

      def dump
        output = []
        puts ""
        puts "Workspace Dump :"
        @determinants.each_value {|v| output.concat v.dump(1)}
        @facts.each_value {|v| output.concat v.dump }
        @factlists.each_value {|v| output.concat v.dump }
        puts ""
        return output
      end
    end
  end
end
