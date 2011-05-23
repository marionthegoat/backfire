module BackfireUtils
  class Sandbox

    CHROOT = "chroot"
    CHMOD = ".chmod"
    CHOWN = ".chown"
    LSTAT = ".lstat"
    STAT = ".stat"
    TRUNCATE = ".truncate"
    UMASK = ".umask"
    FLOCK = ".flock"
    IOCTL = ".ioctl"
    FORK = "fork"
    SYSCALL = "syscall"
    TRAP = "trap"
    SETPGID = ".setpgid"
    SETSID = ".setsid"
    SETPRIORITY = ".setpriority"
    EGID = ".egid"
    SYSTEM = "system" # may require special handling
    SAVE=".save"
    DELETE=".delete"
    DESTROY=".destroy"

    def self.is_safe?(expr)
      return false if expr.include?(CHROOT)
      return false if expr.include?(CHMOD)
      return false if expr.include?(CHOWN)
      return false if expr.include?(LSTAT)
      return false if expr.include?(STAT)
      return false if expr.include?(TRUNCATE)
      return false if expr.include?(UMASK)
      return false if expr.include?(FLOCK)
      return false if expr.include?(IOCTL) 
      return false if expr.include?(FORK)
      return false if expr.include?(SYSCALL)
      return false if expr.include?(TRAP)
      return false if expr.include?(SETPGID)
      return false if expr.include?(SETSID)
      return false if expr.include?(SETPRIORITY)
      return false if expr.include?(EGID)
      return false if expr.include?(SYSTEM)
      return false if expr.include?(SAVE)
      return false if expr.include?(DELETE)
      return false if expr.include?(DESTROY)
      return true
    end

  end
end