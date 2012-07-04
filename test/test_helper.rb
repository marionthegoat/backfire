require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
requier 'miniskirt'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
if ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
elsif ENV['TM_PID']
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMateReporter.new
else
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new
end





