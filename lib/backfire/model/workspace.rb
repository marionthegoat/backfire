module Backfire
  module Model
    class Workspace

      include Backfire::Engine
      include Backfire::Exceptions

      STATE_NEW = "new"
      STATE_LIVE = "live"
      STATE_DEAD = "dead"

      attr_accessor :facts, :factlists, :determinants, :queries, :rules, :engine, :state
      attr_reader :control_params

      # @param [ControlParam] params
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
  #      @dynamic_fact_values=Hash.new
        @engine=Backfire::Engine::BackfireEngine.new(self)
        @state=STATE_NEW
        @control_params=params
      end

      def solve(goal)
        self.engine.solve(goal)
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

      # @param [Determinant] determinant
      def add_determinant(determinant)
         determinant.workspace = self
         get_factoid(determinant.fact_name).add_determinant(determinant) # tell result fact about the new determinant
         gen_facts_from_expression(determinant.expression) # we're cheating here by using expression instead of assertion for Rule case
         gen_facts_from_expression(determinant.predicate) if  determinant.instance_of? Rule
         @determinants[determinant.name.to_sym]=determinant
         @queries[determinant.name.to_sym]=determinant if determinant.instance_of? Query # TODO: Not sure why these are busted out
         @rules[determinant.name.to_sym]=determinant if determinant.instance_of? Rule
         @state = STATE_LIVE if @state == STATE_DEAD
      end

      # this factors the difference between fact and factlist
      def get_factoid(name)
          factoid=get_fact(name)
          return factoid unless factoid.nil?
          factoid=Fact.new(name) if Fact.is_atomic?(name)
          factoid=FactList.new(name) unless Fact.is_atomic?(name)
          add_fact(factoid)
          factoid
      end


      #def dynamic_fact_exists?(value)
      #  !(@dynamic_fact_values[value].nil?)
      #end

      def gen_dynamic_fact_name(value=nil)
        @factseq+=1
        seq=@factseq.to_s
        return value.name + "_" + seq if value.instance_of? Fact
        "dynamic" + "_" + seq
      end

      def scrub_fact_value(value)
        return value.value if value.instance_of? Fact
        value
      end

#      def create_dynamic_fact(value, determinant)
##        puts "create_dynamic_fact value = #{value}"
#        existing=@dynamic_fact_values[value]  #TODO: this seems questionable... May want to always generate new fact containers
#        return existing unless existing.nil?
#        name = gen_dynamic_fact_name(value)
#        newval = scrub_fact_value(value)
#        fact=Fact.new(name, newval, determinant.name)
#        fact.add_determinant(determinant)
#        add_fact(fact)
#        @dynamic_fact_values[value]=fact
#        return fact
#      end


 # we stitch facts and expressions together when expressions are introduced into the workspace
      def gen_facts_from_expression(expression)
          expression.facts.each do |fact|
            fact_instance = get_factoid(fact)
            fact_instance.add_expression(expression)
          end
      end

      def add_query(*queries)
        return if queries.empty?
        query, *rest = queries
        add_determinant(query)
        add_query(*rest)
      end

      def add_rule(*rules)
        return if rules.empty?
        rule, *rest = rules
        add_determinant(rule)
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
