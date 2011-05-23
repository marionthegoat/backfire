require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
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
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Your summary here'
  s.description = s.summary
  s.author = ''
  s.email = ''
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "backfire Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
