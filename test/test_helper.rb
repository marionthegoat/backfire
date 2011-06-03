gem 'test-unit' # LJK had to add this so that RubyMine would find it
require 'test/unit'


# classes for testing lists

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

# classes for poker experiment

class Card
  CLUBS = "Clubs"
  DIAMONDS = "Diamonds"
  HEARTS = "Hearts"
  SPADES = "Spades"
  attr_accessor :rank, :name, :suit
  def initialize(rank, name, suit)
    @rank = rank
    @name = name
    @suit = suit
  end
end

class Deck
  attr_accessor :cards
  def initialize()
    @cards=Array.new( \
      Card.new(1,"Ace",Card::CLUBS) \
    , Card.new(2,"Deuce",Card::CLUBS) \
    , Card.new(3,"Three",Card::CLUBS) \
    , Card.new(4,"Four",Card::CLUBS) \
    , Card.new(5,"Five",Card::CLUBS) \
    , Card.new(6,"Six",Card::CLUBS) \
    , Card.new(7,"Seven",Card::CLUBS) \
    , Card.new(8,"Eight",Card::CLUBS) \
    , Card.new(9,"Nine",Card::CLUBS) \
    , Card.new(10,"Ten",Card::CLUBS) \
    , Card.new(11,"Jack",Card::CLUBS) \
    , Card.new(12,"Queen",Card::CLUBS) \
    , Card.new(13,"King",Card::CLUBS) \
    , Card.new(1,"Ace",Card::DIAMONDS) \
    , Card.new(2,"Deuce",Card::DIAMONDS) \
    , Card.new(3,"Three",Card::DIAMONDS) \
    , Card.new(4,"Four",Card::DIAMONDS) \
    , Card.new(5,"Five",Card::DIAMONDS) \
    , Card.new(6,"Six",Card::DIAMONDS) \
    , Card.new(7,"Seven",Card::DIAMONDS) \
    , Card.new(8,"Eight",Card::DIAMONDS) \
    , Card.new(9,"Nine",Card::DIAMONDS) \
    , Card.new(10,"Ten",Card::DIAMONDS) \
    , Card.new(11,"Jack",Card::DIAMONDS) \
    , Card.new(12,"Queen",Card::DIAMONDS) \
    , Card.new(13,"King",Card::DIAMONDS) \
    , Card.new(1,"Ace",Card::HEARTS) \
    , Card.new(2,"Deuce",Card::HEARTS) \
    , Card.new(3,"Three",Card::HEARTS) \
    , Card.new(4,"Four",Card::HEARTS) \
    , Card.new(5,"Five",Card::HEARTS) \
    , Card.new(6,"Six",Card::HEARTS) \
    , Card.new(7,"Seven",Card::HEARTS) \
    , Card.new(8,"Eight",Card::HEARTS) \
    , Card.new(9,"Nine",CardCard::HEARTS) \
    , Card.new(10,"Ten",Card::HEARTS) \
    , Card.new(11,"Jack",Card::HEARTS) \
    , Card.new(12,"Queen",Card::HEARTS) \
    , Card.new(13,"King",Card::HEARTS) \
    , Card.new(1,"Ace",Card::SPADES) \
    , Card.new(2,"Deuce",Card::SPADES) \
    , Card.new(3,"Three",Card::SPADES) \
    , Card.new(4,"Four",Card::SPADES) \
    , Card.new(5,"Five",Card::SPADES) \
    , Card.new(6,"Six",Card::SPADES) \
    , Card.new(7,"Seven",Card::SPADES) \
    , Card.new(8,"Eight",Card::SPADES) \
    , Card.new(9,"Nine",Card::SPADES) \
    , Card.new(10,"Ten",Card::SPADES) \
    , Card.new(11,"Jack",Card::SPADES) \
    , Card.new(12,"Queen",Card::SPADES) \
    , Card.new(13,"King",Card::SPADES) \
    )
  end
  
end



