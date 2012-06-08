puts File.dirname(__FILE__) + '/test_helper.rb'
require_relative  '../test_helper.rb'
require_relative '../../lib/backfire'

include Backfire::Utils

describe Sandbox do
  # test the exclusions
  it "rejects dangerous statements" do
    Sandbox.is_safe?("Dir.chroot(\"/production/secure/root\")").must_equal false
    Sandbox.is_safe?("File.chmod(0644, \"testfile\", \"out\")").must_equal false
    Sandbox.is_safe?("File.chown(nil, 100, \"testfile\")").must_equal false
    Sandbox.is_safe?("File.lstat(\"link2test\").size").must_equal false
    Sandbox.is_safe?("File.stat(\"testfile\").size").must_equal false
    Sandbox.is_safe?("File.truncate(\"out\", 5)").must_equal false
    Sandbox.is_safe?("File.umask(0006)").must_equal false
    Sandbox.is_safe?("File.new(\"testfile\").flock(File::LOCK_UN)").must_equal false
    Sandbox.is_safe?("ios.ioctl( anIntegerCmd, anArg )").must_equal false
    Sandbox.is_safe?("fork {puts \"this is a fork\"}").must_equal false
    Sandbox.is_safe?("syscall 4, 1, \"hello\n\", 6   # '4' is write(2) on our box").must_equal false
    Sandbox.is_safe?("trap(\"CLD\") { puts \"Child died\" }").must_equal false
    Sandbox.is_safe?("Process.setpgid( aPid, anInteger )").must_equal false
    Sandbox.is_safe?("Process.setsid").must_equal false
    Sandbox.is_safe?("Process.egid").must_equal false
    Sandbox.is_safe?("Process.setpriority(Process::PRIO_USER, 0, 19)").must_equal false
    Sandbox.is_safe?("system(rm *)").must_equal false
    Sandbox.is_safe?("item.save!").must_equal false
    Sandbox.is_safe?("ItemMaster.delete(103)").must_equal false
    Sandbox.is_safe?("ItemMaster.destroy(103)").must_equal false
  end
  # test valid samples
  it "does not reject valid and useful constructs" do
    Sandbox.is_safe?("this is some literal text").must_equal true
    Sandbox.is_safe?("1056").must_equal true
    Sandbox.is_safe?("Time.now").must_equal true
    Sandbox.is_safe?("@fact3.value").must_equal true
    Sandbox.is_safe?("@fact1.value.parent.child.find_by_child_name(\"name\")").must_equal true
  end
end