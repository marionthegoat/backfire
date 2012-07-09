puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative  '../test_sample_classes.rb'
require_relative '../../lib/backfire'

include Backfire::Model
include Backfire::Exceptions
include Backfire::Engine

describe BackfireEngine do

  it "exercises queries to find goal facts" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    w1.add_query(Query.new("when_will_world_end","2012", "end_of_world"))
    goal = w1.engine.solve("end_of_world")
    goal.wont_be_nil
    goal.must_be_instance_of Fact
    goal.value.must_equal 2012
  end

  it "chains rules and queries to determine goal facts" do
    c1 = ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    w1.add_rule(Rule.new("high", "@a.value > @b.value", "c", "@a.value"))
    w1.add_rule(Rule.new("low", "@a.value < @b.value", "c", "@b.value"))
    w1.add_query(Query.new("query_a", "5", "a"))
    w1.add_query(Query.new("query_b", "7", "b"))
    w1.add_query(Query.new("query_d", "@c.value ** 2", "d"))
    goal=w1.solve("d")
    goal.wont_be_nil
    goal.must_be_instance_of Fact
    goal.value.must_equal 49
  end

  it "interrupts execution when prompt query is encountered" do
    c1=ControlParam.new "rulebase_parameters"
    w1 = Workspace.new(c1)
    w1.add_rule(Rule.new("scales", "@cat_has_on_mouth.value == 'feathers'", "cat_ate", "'bird'"))
    w1.add_rule(Rule.new("feathers", "@cat_has_on_mouth.value == 'scales'", "cat_ate", "'fish''"))
    w1.add_rule(Rule.new("fur", "@cat_has_on_mouth.value == 'fur'", "cat_ate", "'mouse''"))
    w1.add_query(Query.new("mittens", "'Mittens'", "cat"))
    w1.add_query(Query.new("evidence_prompt", "What does the cat @cat have around its mouth?", "cat_has_on_mouth", true))  # this is a prompt query
    goal=w1.solve("cat_ate")
    goal.wont_be_nil
    goal.must_equal BackfireEngine::PROMPT
    w1.current_query.wont_be_nil
    w1.current_query.name.must_equal "evidence_prompt"
    w1.current_query.expression.resolved_expr.must_equal "What does the cat Mittens have around its mouth?"
    w1.prompt_response = "feathers"
    goal=w1.solve("cat_ate")
    goal.wont_be_nil
    goal.must_be_instance_of Fact
    goal.value.must_equal "bird"
    w1.current_query.must_be_nil
    w1.dump
  end

  it "handles combinatorial interaction of factlists when evaluating expressions" do
    p=ControlParam.new "test"
    workspace = Workspace.new(p)
    # this is simply exercising how the expressions get exploded over factlists, isn't meant to be anything profound
    # The rules are that I like frogs in any setting, I like beetles period, and I like anything which eats insects.
    # The 'any' aspect simply gets filled with the relevant factlist
    f1 = Fact.new("animal1","frog","initial load")
    f2 = Fact.new("animal2","snail", "initial load")
    f3 = Fact.new("animal3","beetle", "initial load")
    f4 = Fact.new("habitat1", "jungle", "initial load")
    f5 = Fact.new("habitat2", "desert", "initial load")
    f6 = Fact.new("habitat6", "tundra", "initial load")
    f7 = Fact.new("habitat7", "tundra", "initial load")
    f8 = Fact.new("food1", "leaves", "initial load")
    f9 = Fact.new("food2", "algae", "initial load")
    f10 = Fact.new("food3", "insects", "initial load")
    l1 = FactList.new("Animals")
    l1.add_member(f1, f2, f3)
    workspace.add_fact(l1)
    l2=FactList.new("Habitats")
    l2.add_member(f4, f5, f6, f7)
    workspace.add_fact(l2)
    l3=FactList.new("Foods")
    l3.add_member(f8, f9, f10)
    workspace.add_fact(l3)
    r1=Rule.new("RULE1", Expression.parse("@Animals.value == \"frog\" && @Habitats.value.nil? == false"), "I_like", Expression.parse("@Animals.value + \"s in the \" + @Habitats.value"))
    r2 =Rule.new("RULE2", Expression.parse("@Animals.value == \"beetle\""), "I_like", Expression.parse("@Animals.value"))
    r3=Rule.new("RULE3", Expression.parse("@Animals.value.nil? == false && @Foods.value == \"insects\""), "I_like", Expression.parse("@Animals.value + \"s that eat \" + @Foods.value"))
    workspace.add_rule(r1)
    workspace.add_rule(r2)
    workspace.add_rule(r3)
    result = workspace.engine.solve("I_like")
#    puts "Result = #{result.values.inspect}" unless result.nil?
    #    workspace.why(m.name)
    #  end
    #end
#    workspace.dump
    result.wont_be_nil
    result.members.size.must_equal 7
    result.fact_values.must_include "beetle"
    result.fact_values.must_include "frogs in the desert"
    result.fact_values.must_include "snails that eat insects"
  end

  it "does it again differently" do
    p=ControlParam.new "test"
    workspace = Workspace.new(p)
    l1 = FactList.new("Animals",["frog","snail","beetle"],"initial_load",workspace)
    l2=FactList.new("Habitats",["jungle","desert","tundra"], "initial_load", workspace)
    l3=FactList.new("Foods", ["leaves","algae","insects"], "initial_load", workspace)
    r1=Rule.new("RULE1", Expression.parse("@Animals.value == \"frog\" && @Habitats.value.nil? == false"), "I_like", Expression.parse("@Animals.value + \"s in the \" + @Habitats.value"),workspace)
    r2 =Rule.new("RULE2", Expression.parse("@Animals.value == \"beetle\""), "I_like", Expression.parse("@Animals.value"), workspace)
    r3=Rule.new("RULE3", Expression.parse("@Animals.value.nil? == false && @Foods.value == \"insects\""), "I_like", Expression.parse("@Animals.value + \"s that eat \" + @Foods.value"), workspace)
    result = workspace.engine.solve("I_like")
    result.wont_be_nil
    result.members.size.must_equal 7
    result.fact_values.must_include "beetle"
    result.fact_values.must_include "frogs in the desert"
    result.fact_values.must_include "snails that eat insects"
  end

  it "handles propogation of dependent lists in predicates" do
    # this test will create some new working list from existing lists, and use those to solve goal lists
    p=ControlParam.new("test")
    workspace = Workspace.new(p)
    p1=Person.new("Igor", 34, "M", ["razor", "keys", "toothpick"])
    p2=Person.new("Suzanne", 28, "F", ["mace", "lipstick", "wallet"])
    p3=Person.new("Hilda", 45, "F", ["pistol", "aspirin", "cream pie"])
    p4=Person.new("Gary", 55, "M", ["pistol", "knife", "newspaper"])
    p5=Person.new("Steve", 42, "M", ["sandwich", "cell phone"])
    w1=Weapon.new("knife", "cut")
    w2=Weapon.new("pistol", "shot")
    w3=Weapon.new("razor", "cut")
    w4=Weapon.new("water balloon", "wet")
    w5=Weapon.new("cream pie", "mess")
    f1=Fact.new(p1.name.downcase, p1, "initial_load", workspace)
    f2=Fact.new(p2.name.downcase, p2, "initial_load", workspace)
    f3=Fact.new(p3.name.downcase, p3, "initial_load", workspace)
    f4=Fact.new(p4.name.downcase, p4, "initial_load", workspace)
    f5=Fact.new(p5.name.downcase, p5, "initial_load", workspace)
    f6=Fact.new(w1.name.downcase, w1, "initial_load", workspace)
    f7=Fact.new(w2.name.downcase, w2, "initial_load", workspace)
    f8=Fact.new(w3.name.downcase, w3, "initial_load", workspace)
    f9=Fact.new(w4.name.downcase, w4, "initial_load", workspace)
    f10=Fact.new(w5.name.downcase, w5, "initial_load", workspace)
    l1=FactList.new("Persons",[f1,f2,f3,f4,f5], "initial_load", workspace)
    l2=FactList.new("Weapons",[f6, f7, f8, f9, f10], "initial load", workspace)
    f9=Fact.new("suspect_age_high", 40, "initial_load", workspace)
    f10=Fact.new("suspect_age_low", 30, "initial_load", workspace)
    f11=Fact.new("suspect_gender", "M", "initial_load", workspace)
    f12=Fact.new("cause_of_death", "cut", "initial_load", workspace)
 #   workspace.add_fact(f9,f10,f11,f12)
    r1=Rule.new( "DEADLY_WEAPONS", Expression.parse("[\"pistol\",\"razor\",\"knife\"].include?(@Weapons.value.name) "),"Deadly_weapons",  Expression.parse("@Weapons.value"), workspace )
    r2=Rule.new( "POSSIBLE_PERSONS", Expression.parse("@Persons.value.age <= @suspect_age_high.value && @Persons.value.age >= @suspect_age_low.value && @Persons.value.gender == @suspect_gender.value"),
                 "Possible_persons", Expression.parse("@Persons.value"), workspace)
    r3=Rule.new( "POSSIBLE_WEAPONS", Expression.parse("@Deadly_weapons.value.damage == @cause_of_death.value"), "Possible_weapons",  Expression.parse("@Deadly_weapons.value"), workspace)
    r4=Rule.new( "SUSPECTED_PERSONS", Expression.parse("@Possible_persons.value.posessions.include?(@Possible_weapons.value.name)"), "Suspected_persons", Expression.parse("@Possible_persons.value"), workspace)
    r5=Rule.new( "SUSPECTED_WEAPONS", Expression.parse("@Suspected_persons.value.posessions.include?(@Possible_weapons.value.name)"), "Suspected_weapons", Expression.parse("@Possible_weapons.value"), workspace)
 #   workspace.add_rule(r1, r2, r3, r4, r5)
    result=workspace.engine.solve("Suspected_persons")
    unless result.nil?
      result.members.each do |m|
        puts "Result #{result.name} = #{m.value.name} : #{m.value}"
      end
    end
    result.fact_values[0].name.must_equal "Igor"
    result=workspace.engine.solve("Suspected_weapons")
    unless result.nil?
      result.members.each do |m|
        puts "Result #{result.name} = #{m.value.name} : #{m.value}"
      end
    end
    result.fact_values[0].name.must_equal "razor"
 #   workspace.dump
  end

end