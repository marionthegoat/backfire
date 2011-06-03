require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
# require 'rdoc/task'
require 'rake/testtask'
#
# Rake file tries to load all the test classes prior to /lib being added to the Ruby path
# Because of this, we must do explicit loads here... the normal path mechanism used by backfire.rb isn't available yet
#
require File.dirname(__FILE__) +  '/lib/backfire/exceptions/backfire_exception'
require File.dirname(__FILE__) +  '/lib/backfire/utils/sandbox'
require File.dirname(__FILE__) +  '/lib/backfire/model/control_param'
require File.dirname(__FILE__) +  '/lib/backfire/model/determinant'
require File.dirname(__FILE__) +  '/lib/backfire/model/expression'
require File.dirname(__FILE__) +  '/lib/backfire/model/fact'
require File.dirname(__FILE__) +  '/lib/backfire/model/fact_list'
require File.dirname(__FILE__) +  '/lib/backfire/model/query'
require File.dirname(__FILE__) +  '/lib/backfire/model/rule'
require File.dirname(__FILE__) +  '/lib/backfire/engine/backfire_engine'
require File.dirname(__FILE__) +  '/lib/backfire/model/workspace'


spec = Gem::Specification.new do |s|
  s.name = 'backfire'
  s.version = '0.0.1'
  s.has_rdoc = false
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = "Simple back-chaining rule engine"
  s.description = "#{s.summary}...   This is the ruby-only portion of a simple rule engine which uses back-chaining as its primary inference mechanism. See backfire_rails for rails plugin extensions."
  s.author = 'Lonnie Knechtel aka MarionTheGoat'
  s.email = 'lonnie@ndsapps.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

# The rdoc stuff is giving me this :
# [rake --prereqs] rake/rdoctask is deprecated.  Use rdoc/task instead (in RDoc 2.4.2+)
# C:/Ruby192/lib/ruby/1.9.1/rdoc/task.rb:30: warning: already initialized constant Task
# Not sure why... both rake and rdoc gems are up to date... commented out for now
#
#RDoc::Task.new do |rdoc|
#  files =['README', 'LICENSE', 'lib/**/*.rb']
#  rdoc.rdoc_files.add(files)
#  rdoc.main = "README" # page to start on
#  rdoc.title = "backfire Docs"
#  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
#  rdoc.options << '--line-numbers'
#end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
