require_relative  'test_helper.rb'

class B0EngineTest < Test::Unit::TestCase

  include Backfire::Model
  include Backfire::Engine

  def test1_cartesian_product
    # Exercises home-cooked cartesian product
    x=[1,3,4,7,8,11]
    y=["frog", "snail", "beetle"]
    a=BackfireEngine.product(x,y)
    assert_equal 18, a.length
    assert_equal [3,"beetle"], a[5]
    z=["green", "yellow", "orange", "blue"]
    b=BackfireEngine.product(a,z)
    assert_equal 72, b.length
    assert_equal [4, "frog", "blue"], b[27]
  end

  def test2_factlist_eval
    # Exercises basic FactList evaluation, predicate reference, and aggregation as receiver
    puts " "
    p=ControlParam.new("test",ControlParam::BACKCHAIN_ONLY,20,ControlParam::OPTION_YES)
    workspace = Workspace.new(p)
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
    r2 =Rule.new("RULE2", Expression.parse("@Animals.value == \"beetle\""), "I_like", Expression.parse("@Animals"))
    r3=Rule.new("RULE3", Expression.parse("@Animals.value.nil? == false && @Foods.value == \"insects\""), "I_like", Expression.parse("@Animals.value + \"s that eat \" + @Foods.value"))
    workspace.add_rule(r1)
    workspace.add_rule(r2)
    workspace.add_rule(r3)
    result = workspace.engine.solve("I_like")
    unless result.nil?
      result.members.each do |m|
        puts "Result #{result.name} = #{m.name} : #{m.value}"
      end
    end
    unless result.nil?
      result.members.each do |m|
        workspace.why(m.name)
      end
    end
    workspace.dump
  end

  def test3_dependent_lists
    puts""
    puts"WHODUNIT Test :"
    puts""
    # this test will create some new working list from existing lists, and use those to solve goal lists
      p1=Person.new("Igor", 34, "M", ["razor", "keys", "toothpick"])
      p2=Person.new("Suzanne", 28, "F", ["mace", "lipstick", "wallet"])
      p3=Person.new("Hilda", 45, "F", ["pistol", "asprin"])
      p4=Person.new("Gary", 55, "M", ["pistol", "knife", "newspaper"])
      p5=Person.new("Steve", 42, "M", ["sandwich", "cell phone"])
      w1=Weapon.new("knife", "cut")
      w2=Weapon.new("pistol", "shot")
      w3=Weapon.new("razor", "cut")
      w4=Weapon.new("water balloon", "wet")
      w5=Weapon.new("cream pie", "mess")
      f1=Fact.new(p1.name.downcase, p1, "initial_load")
      f2=Fact.new(p2.name.downcase, p2, "initial_load")
      f3=Fact.new(p3.name.downcase, p3, "initial_load")
      f4=Fact.new(p4.name.downcase, p4, "initial_load")
      f5=Fact.new(p5.name.downcase, p5, "initial_load")
      f6=Fact.new(w1.name.downcase, w1, "initial_load")
      f7=Fact.new(w2.name.downcase, w2, "initial_load")
      f8=Fact.new(w3.name.downcase, w3, "initial_load")
      f9=Fact.new(w4.name.downcase, w4, "initial_load")
      f10=Fact.new(w5.name.downcase, w5, "initial_load")
      l1=FactList.new("Persons")
      l1.add_member(f1,f2,f3,f4,f5)
      l2=FactList.new("Weapons")
      l2.add_member(f6, f7, f8, f9, f10)
      p=ControlParam.new("test",ControlParam::BACKCHAIN_ONLY,20,ControlParam::OPTION_YES)
      workspace = Workspace.new(p)
      workspace.add_fact(l1,l2)
      f9=Fact.new("suspect_age_high", 40, "initial_load")
      f10=Fact.new("suspect_age_low", 30, "initial_load")
      f11=Fact.new("suspect_gender", "M", "initial_load")
      f12=Fact.new("cause_of_death", "cut", "initial_load")
      workspace.add_fact(f9,f10,f11,f12)
      r1=Rule.new( "DEADLY_WEAPONS", Expression.parse("[\"pistol\",\"razor\",\"knife\"].include?(@Weapons.value.name) "),"Deadly_weapons",  Expression.parse("@Weapons") )
      r2=Rule.new( "POSSIBLE_PERSONS", Expression.parse("@Persons.value.age <= @suspect_age_high.value && @Persons.value.age >= @suspect_age_low.value && @Persons.value.gender == @suspect_gender.value"),
          "Possible_persons", Expression.parse("@Persons"))
      r3=Rule.new( "POSSIBLE_WEAPONS", Expression.parse("@Deadly_weapons.value.damage == @cause_of_death.value"), "Possible_weapons",  Expression.parse("@Deadly_weapons"))
      r4=Rule.new( "SUSPECTED_PERSONS", Expression.parse("@Possible_persons.value.posessions.include?(@Possible_weapons.value.name)"), "Suspected_persons", Expression.parse("@Possible_persons"))
      r5=Rule.new( "SUSPECTED_WEAPONS", Expression.parse("@Suspected_persons.value.posessions.include?(@Possible_weapons.value.name)"), "Suspected_weapons", Expression.parse("@Possible_weapons"))
      workspace.add_rule(r1, r2, r3, r4, r5)
      result=workspace.engine.solve("Suspected_persons")
      unless result.nil?
        result.members.each do |m|
          puts "Result #{result.name} = #{m.value.name} : #{m.value}"
        end
      end
      assert_equal  "Igor", result.members[0].value.name
      result=workspace.engine.solve("Suspected_weapons")
      unless result.nil?
        result.members.each do |m|
          puts "Result #{result.name} = #{m.value.name} : #{m.value}"
        end
      end
      assert_equal "razor", result.members[0].value.name
      workspace.dump
  end

end
