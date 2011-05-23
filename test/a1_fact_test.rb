require File.dirname(__FILE__) + '/test_helper.rb'
require 'backfire'

class A1FactTest < Test::Unit::TestCase
  include Backfire::Model
  include Backfire::Exceptions

  def test_create
    @f1 = Fact.new "test_fact", 18, "Initial Load"
    assert_equal "test_fact", @f1.name
    assert_equal 18, @f1.value
    assert_equal "Initial Load", @f1.origin
  end

  def test_protect
    assert_raise(BackfireException) {f2=Fact.new("BadFactName", "some value", "bad_test")}
  end

  def test_indeterminate
    f2 = Fact.new("i_dunno")
    assert_equal true, f2.is_indeterminate?
    f2.value = "huh?"
    assert_equal false, f2.is_indeterminate?
  end

  def test_atomic
    f3=Fact.new("some_name")
    assert_equal true, f3.is_atomic?
  end


end
