require_relative  'test_helper.rb'
require_relative '../lib/backfire'
class A5SandboxTest < Test::Unit::TestCase

  include BackfireUtils

  def test_sandbox_is_safe
    # test the exclusions
    assert_equal false, Sandbox.is_safe?("Dir.chroot(\"/production/secure/root\")")
    assert_equal false, Sandbox.is_safe?("File.chmod(0644, \"testfile\", \"out\")")
    assert_equal false, Sandbox.is_safe?("File.chown(nil, 100, \"testfile\")")
    assert_equal false, Sandbox.is_safe?("File.lstat(\"link2test\").size")
    assert_equal false, Sandbox.is_safe?("File.stat(\"testfile\").size")
    assert_equal false, Sandbox.is_safe?("File.truncate(\"out\", 5)")
    assert_equal false, Sandbox.is_safe?("File.umask(0006)")
    assert_equal false, Sandbox.is_safe?("File.new(\"testfile\").flock(File::LOCK_UN)")
    assert_equal false, Sandbox.is_safe?("ios.ioctl( anIntegerCmd, anArg )")
    assert_equal false, Sandbox.is_safe?("fork {puts \"this is a fork\"}")
    assert_equal false, Sandbox.is_safe?("syscall 4, 1, \"hello\n\", 6   # '4' is write(2) on our box")
    assert_equal false, Sandbox.is_safe?("trap(\"CLD\") { puts \"Child died\" }")
    assert_equal false, Sandbox.is_safe?("Process.setpgid( aPid, anInteger )")
    assert_equal false, Sandbox.is_safe?("Process.setsid")
    assert_equal false, Sandbox.is_safe?("Process.egid")
    assert_equal false, Sandbox.is_safe?("Process.setpriority(Process::PRIO_USER, 0, 19)")
    assert_equal false, Sandbox.is_safe?("system(rm *)")
    assert_equal false, Sandbox.is_safe?("item.save!")
    assert_equal false, Sandbox.is_safe?("ItemMaster.delete(103)")
    assert_equal false, Sandbox.is_safe?("ItemMaster.destroy(103)")
    # test valid samples
    assert_equal true, Sandbox.is_safe?("this is some literal text")
    assert_equal true, Sandbox.is_safe?("1056")
    assert_equal true, Sandbox.is_safe?("Time.now")
    assert_equal true, Sandbox.is_safe?("@fact3.value")
    assert_equal true, Sandbox.is_safe?("@fact1.value.parent.child.find_by_child_name(\"name\")")
  end
end
