module Backfire
  module Engine
    class BackfireEngine
      PROMPT = "prompt"

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
          if Fact.is_atomic?(fact)
            puts "ERROR : MISSING FACT #{fact}, workspace not loaded correctly." if @workspace.get_fact(fact).nil?
            #    value=nil
            value=solve_sub(fact, level+1) if @workspace.get_fact(fact).is_indeterminate?
            return value if value == PROMPT
            indeterminate = true if @workspace.get_fact(fact).is_indeterminate?
            puts "unable to resolve value for #{fact}" if indeterminate
            #        puts "fact value = #{@workspace.facts[fact.to_sym].value}" unless indeterminate
            if determinant.is_a?(Query) && determinant.is_prompt?
              expr_string = expr_string.gsub("@#{fact}", @workspace.facts[fact.to_sym].value.to_s)
            else
              expr_string = expr_string.gsub("@#{fact}", "\"@workspace.facts[\"#{fact}\".to_sym]\"") if value.is_a?(String)
              expr_string = expr_string.gsub("@#{fact}", "@workspace.facts[\"#{fact}\".to_sym]") unless value.is_a?(String)
            end
          end
        end
        if determinant.is_a?(Query) && determinant.is_prompt?
          determinant.expression.resolved_expr=expr_string
          @workspace.current_query = determinant
          return PROMPT # token which terminates evaluation when input is required from user
        end
        #    puts "Evaluation of rule predicate #{expr_string}" if is_predicate
        return false if indeterminate
        # deal with fact lists separately
        determinant.expression.factlists.each do |list|
          #      puts "Greedy fact list solve for #{list} level #{level+1}"
          result = solve_sub(list,level+1) unless @workspace.get_fact(list).is_true?
          return result if result == PROMPT
        end unless is_predicate
        evaluate_single(determinant, expr_string, level) unless determinant.expression_has_factlist? && is_predicate==false
        evaluate_factlists(determinant, expr_string, level) if determinant.expression_has_factlist? unless is_predicate
        true
      end

      def solve(goal)
#        puts "[BackfireEngine] solve goal = #{goal}"
        last_x=nil
        for i in 0..20  #temporary protection against runaway
          x=solve_sub(goal)
          last_x = x unless x.nil?
#          puts "solve, goal_fact = #{goal} result = #{x}"
#          puts "Solve discovery = #{@discovery} last_x = #{last_x}"
          return last_x if @discovery == false
        end
        return nil
      end

      def solve_sub(goal, level=0)
        # convention : goal fact name is used here
        @discovery=false if level == 0 # initialize discovery tracking variable
        goal_fact = @workspace.get_fact(goal)
        puts "ERROR : unknown goal fact #{goal}, exiting solve_sub" if goal_fact.nil?
        return nil if goal_fact.nil?
 #       puts "solve_sub goal_fact = #{goal_fact.name} value = #{goal_fact.value} state = #{goal_fact.state}" unless goal_fact.is_list?
 #       puts "goal_fact = #{goal_fact} state = #{goal_fact.state}"
        return goal_fact if goal_fact.is_true? unless goal_fact.instance_of?(FactList)  # this prevents facts from being re-determined by lower-priority rules
        # Action here is different for list
        return goal_fact unless goal_fact.instance_of?(FactList) || goal_fact.is_indeterminate?
  #      puts "evaluating determinants for #{goal_fact.name} goal_fact.determinants=#{goal_fact.determinants}"
        goal_fact.determinants.each do |det|
  #        puts "** SOLVE GOAL SEEK determinant = #{det.name} state = #{det.state}"
          if det.is_indeterminate?
 #                    puts "Evaluating #{det.name} type = #{det.class}"
            result = evaluate(det, level+1)
            return result if result == PROMPT
            #         puts("result = #{result} state = #{det.state} fact = #{det.fact}")
            #          puts "[BackfireEngine.solve_sub] det.class = #{det.class}"
            return goal_fact if (det.is_true? && result) unless (@discovery && goal_fact.instance_of?(FactList))
          end
        end
        @workspace.state = Workspace::STATE_DEAD if level == 0 unless @discovery
  # break out if nothing discovered
 #       if @workspace.is_dead?
          return goal_fact
#       end
        # don't think we'll ever get here
#        return nil
      end

      def evaluate_single(determinant, expr_string, level, fact_instances=nil)
#        puts "evaluate, expression string = #{expr_string}"
        determinant.expression.resolved_expr=expr_string
        begin
          result = eval expr_string
        rescue Exception => err
          puts "Eval failed, error = #{err}"
          @workspace.dump
          puts "Statement in error = #{expr_string}"
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
                  determinant.fact.add_member(Fact.new(nil, result, determinant, @workspace)) # we're using longhand form because we want proper origin in there
              end
            else
              determinant.fact.value = result
              determinant.fact.origin = determinant.name
            end
            determinant.state = Determinant::STATE_TRUE
            @discovery = true
          end
        end
      end

      def evaluate_factlists(determinant, expr_string, level)
        #    puts "Engine.evaluate_factlists expr = #{expr_string}"
        product_array = []
        first=true
        if determinant.expression.factlists.length == 1
          # boundary case -- can't do cartesian product on single array
          product_array = single_product(@workspace.facts[determinant.expression.factlists[0].to_sym].members)
        else
          determinant.expression.factlists.each do |list|
#            puts "evaluate_factlists adding #{list} to product"
            product_array= @workspace.facts[list.to_sym].members if first
            product_array=BackfireEngine.product(product_array, @workspace.facts[list.to_sym].members) unless first
            first=false
          end
        end
        product_array.each do |p|
#               puts "Product row = #{p}"
          expr = expr_string
          fact_instances=Hash.new #
          for i in 0..determinant.expression.factlists.length-1 do
            factlist=determinant.expression.factlists[i]
            expr = expr.gsub("@"+@workspace.facts[factlist.to_sym].name, "@workspace.facts[\"#{p[i].name}\".to_sym]")
            fact_instances[factlist.to_sym]=p[i]
          end
#          puts "evaluate_factlists expr = #{expr}"
          evaluate_single(determinant, expr, level, fact_instances)
        end
      end

      def evaluate_predicate(rule, level, fact_instances)
        if rule.is_true?
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