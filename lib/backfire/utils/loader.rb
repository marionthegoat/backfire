class Loader
  #TODO this probably belongs in separate gem
  def initialize(workspace)
    @workspace = workspace
  end

  def load_rules(rule_class, conditions=nil)
    # load directly from database
    conditions=:all if conditions.nil?
    instances=rule_class.constantize.send("find", conditions)
    instances.each do |rule|
      @workspace.add_rule(rule.rule_instance)
    end
  end

# @param [Class] query_class
# @param [Object] conditions
  def load_queries(query_class, conditions=nil)
    #load directly from database
    conditions=:all if conditions.nil?
    instances=query_class.constantize.send("find", conditions)
    instances.each do |query|
      @workspace.add_query(query.query_instance)
    end
  end

end