# classes for engine testing

class Person
  attr_accessor :name, :age, :gender, :posessions
  def initialize (name, age, gender, posessions=[])
    @name=name
    @age=age
    @gender = gender
    @posessions=posessions
  end
end

class Weapon
  attr_accessor :name, :damage
  def initialize (name, damage)
    @name=name
    @damage=damage
  end
end
