require File.dirname(__FILE__) + '/test_helper.rb'
require 'backfire'

class A2FactListTest < Test::Unit::TestCase
  include Backfire::Model
  include Backfire::Exceptions

  def test_create
    f1 = FactList.new("My_list")
    assert_equal "My_list", f1.name
    assert_equal FactList::STATE_INDETERMINATE, f1.state
  end

  def test_protect
    assert_raise (BackfireException) { f2=FactList.new("bad_name")}
  end

  def test_add_member
    f3 = FactList.new("My_list")
    assert_raise (BackfireException) { f3.add_member("bad fact")}
    f3.add_member(Fact.new("real_fact","really","unit test"))
    assert_equal FactList::STATE_TRUE, f3.state
  end

end
