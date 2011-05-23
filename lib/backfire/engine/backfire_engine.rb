module Backfire
  module Engine
    class BackfireEngine

      include Backfire::Model
      include Backfire::Exceptions

      def initialize(workspace)
        @workspace = workspace
        @discovery = false
      end

      def evaluate(determinant, level=0, is_predicate=false)
        indeterminate=false
        value=nil
        # first-cut, no class fact arguments
        expr_string = determinant.expression.expression.clone
        determinant.expression.facts.each do |fact|
          puts "ERROR : MISSING FACT #{fact}, workspace not loaded correctly." if @workspace.facts[fact.to_sym].nil?
          #    value=nil
          solve_sub(fact, level+1) if @workspace.facts[fact.to_sym].is_indeterminate?
          indeterminate = true if @workspace.facts[fact.to_sym].is_indeterminate?
          puts "unable to resolve value for #{fact}" if indeterminate
          #        puts "fact value = #{@workspace.facts[fact.to_sym].value}" unless indeterminate
          expr_string = expr_string.sub("@#{fact}", "\"@workspace.facts[\"#{fact}\".to_sym]\"") if value.class == String
          expr_string = expr_string.sub("@#{fact}", "@workspace.facts[\"#{fact}\".to_sym]") unless value.class == String
        end
        #    puts "Evaluation of rule predicate #{expr_string}" if is_predicate
        return false if indeterminate
        determinant.expression.factlists.each do |list|
          #      puts "Greedy fact list solve for #{list} level #{level+1}"
          solve_sub(list,level+1) unless @workspace.factlists[list.to_sym].state == FactList::STATE_TRUE
        end unless is_predicate
        evaluate_single(determinant, expr_string, level) unless determinant.expression_has_factlist? && is_predicate==false
        evaluate_factlists(determinant, expr_string, level) if determinant.expression_has_factlist? unless is_predicate
        return true
      end

      def solve(goal)
        last_x=nil
        for i in 0..20  #temporary protection against runaway
          x=solve_sub(goal)
          last_x = x unless x.nil?
          puts "Solve discovery = #{@discovery} last_x = #{last_x}"
          return last_x if @discovery == false
        end
        return nil
      end

      def solve_sub(goal, level=0)
        # convention : goal fact name is used here
        @discovery=false if level == 0 # initialize discovery tracking variable
        # fire unconditional rules first
        fire_unconditional_rules if level == 0
        goal_fact = @workspace.facts[goal.to_sym] if Fact.is_atomic?(goal)
        goal_fact = @workspace.factlists[goal.to_sym] if Fact.is_list?(goal)
        puts "ERROR : unknown goal fact #{goal}, exiting solve_sub" if goal_fact.nil?
        return nil if goal_fact.nil?
        #    puts "solve_sub goal_fact = #{goal_fact.name} value = #{goal_fact.value} state = #{goal_fact.state}" unless goal_fact.is_list?
        return goal_fact if goal_fact.state == Fact::STATE_TRUE unless goal_fact.is_list? # this prevents facts from being re-determined by lower-priority rules
        # Action here is different for list
        return goal_fact unless goal_fact.is_list? || goal_fact.state == Fact::STATE_INDETERMINATE
        goal_fact.determinants.each do |det|
          #       puts "** SOLVE GOAL SEEK determinant = #{det.name} state = #{det.state}"
          if det.state == Determinant::STATE_INDETERMINATE
            #         puts "Evaluating #{det.name} type = #{det.class}"
            result = evaluate(det, level+1)
            #         puts("result = #{result} state = #{det.state} fact = #{det.fact}")
            #          puts "[BackfireEngine.solve_sub] det.class = #{det.class}"
            if result && det.class == Query
              # should have the value in fact, need to do all completion stuff
              return goal_fact unless (@discovery && goal_fact.is_list?)
            end
            #         puts "It's a rule ..." if det.class == Rule
            if result && det.class == Rule && det.state == Determinant::STATE_TRUE
              return goal_fact unless (@discovery && goal_fact.is_list?)
            end
          end
          @workspace.state = Workspace::STATE_DEAD if level == 0 unless @discovery
          # break out if nothing discovered
          if @workspace.state == Workspace::STATE_DEAD
            return goal_fact
          end
        end
        # don't think we'll ever get here
        return nil
      end

      def fire_unconditional_rules
        @workspace.unconditional_rules.each do |u|
          ufact=nil
          if u.state == Determinant::STATE_INDETERMINATE
            #        puts "evaluating unconditional rule #{u.name}"
            u.state = Determinant::STATE_TRUE
            ufact=u.fact.name unless u.fact.nil?
            upred=Query.new(u.name+" Predicate", u.predicate, ufact)
            evaluate(upred);
          end
        end
      end

      def evaluate_single(determinant, expr_string, level, fact_instances=nil)
        #    puts "evaluate, expression string = #{expr_string}"
        determinant.expression.resolved_expr=expr_string
        begin
          result = eval expr_string
        rescue Exception => err
          puts "Eval failed, error = #{err}"
          @workspace.dump
          raise Backfire::Exceptions::BackfireException,err
        end
        if determinant.class == Rule
          #      puts "Rule #{determinant.name} is #{result}"
          determinant.state = Determinant::STATE_TRUE if result == true
          determinant.state = Determinant::STATE_FALSE unless result == true
          evaluate_predicate(determinant,level,fact_instances) if result == true
          #      puts "evaluate_single for Rule #{determinant.name}, determinant.fact = #{determinant.fact}"
        else
          #      puts "Determinant #{determinant.name} Fact is nil" if determinant.fact.nil?
          # must be query
          unless determinant.fact.nil?
            #        puts "#{determinant.name}: query yields value : #{result} for #{determinant.fact.name} class #{determinant.fact.class.name}"
            if determinant.fact.is_list?
              #          puts "FactList #{determinant.fact.name} is receiver"
              determinant.fact.add_member(result) if result.class.name == "Fact"
              # wrap non-fact results in new fact instance (caveat emptor : rules won't be able to access except via the list)
              unless result.class.name == "Fact"
                unless @workspace.dynamic_fact_exists?(result)
                  determinant.fact.add_member(@workspace.create_dynamic_fact(result, determinant))
                  @discovery = true
                end
              end
            else
              @discovery = true
              determinant.fact.value = result
              determinant.fact.origin = determinant.name
              determinant.state = Determinant::STATE_TRUE
            end
          end
        end
      end

      def evaluate_factlists(determinant, expr_string, level)
        #    puts "Engine.evaluate_factlists expr = #{expr_string}"
        product_array = []
        first=true
        if determinant.expression.factlists.length == 1
          # boundary case -- can't do cartesian product on single array
          product_array = single_product(@workspace.factlists[determinant.expression.factlists[0].to_sym].members)
        else
          determinant.expression.factlists.each do |list|
            #      puts "evaluate_factlists adding #{list} to product"
            product_array= @workspace.factlists[list.to_sym].members if first
            product_array=BackfireEngine.product(product_array, @workspace.factlists[list.to_sym].members) unless first
            first=false
          end
        end
        product_array.each do |p|
          #      puts "Product row = #{p}"
          expr = expr_string
          fact_instances=Hash.new #
          for i in 0..determinant.expression.factlists.length-1 do
            factlist=determinant.expression.factlists[i]
            expr = expr.gsub("@"+@workspace.factlists[factlist.to_sym].name, "@workspace.facts[\"#{p[i].name}\".to_sym]")
            fact_instances[factlist.to_sym]=p[i]
          end
          #      puts "evaluate_factlists expr = #{expr}"
          evaluate_single(determinant, expr, level, fact_instances)
        end
      end

      def evaluate_predicate(rule, level, fact_instances)
        if rule.state == Rule::STATE_TRUE
          # Rule fired true, attempt to resolve fact value expression
          #        puts "evaluate_predicate before fact_instances expr=#{rule.predicate.expression} instances = #{fact_instances}"
          pred=Query.new(rule.name+" Predicate", Expression.parse(rule.predicate.expression), rule.fact.name)
          @workspace.add_query(pred) # gets it linked up properly
          # If predicate references factlist(s), the specific values from those lists are dubbed in here
          # we do this after initial parse so @workspace doesn't get seen as a fact
          pred_expr = pred.expression.expression
          unless fact_instances.nil?
            fact_instances.each do |key, value|
              pred_expr=pred_expr.gsub("@"+key.to_s,"@workspace.facts[\"#{value.name}\".to_sym]" )
            end
          end
          pred.expression.expression = pred_expr
          #        puts "Evaluating predicate expression for #{rule.name} to assign #{rule.fact.name} predicate = #{pred_expr}"
          q=evaluate(pred,level+1, true)
          pred.fact.origin="#{rule.class.name}: #{rule.name}" if pred.fact.is_atomic?
          @discovery=true
          @workspace.state=Workspace::STATE_LIVE
          return pred.fact if q
        end
        return nil
      end


      # creates cartesian product from input arrays
      # There's probably a more clever way to do this
      # TODO : this gets replaced by Array.product() in Ruby 1.9
      def self.product(a1, a2)
        aprod=[]
        a1.map do |x|
          a2.map do |y|
            aprod << x + [y] if x.class.name == "Array"
            aprod << [x,y] unless x.class.name == "Array"
          end
        end
        return aprod
      end

      def single_product(a1)
        #    puts "Invoking single_product ..."
        aprod=[]
        a1.map do |x|
          aprod << [x]
        end
        return aprod
      end

    end
  end
end