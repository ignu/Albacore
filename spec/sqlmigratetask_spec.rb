require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/migrator'
require 'rake/sqlmigratetask'

describe "when execution fails" do 
  before :all do 
    sqlmigrate :fail do |t|
      t.extend(FailPatch)
      t.fail
    end 
    Rake::Task[:fail].invoke
  end 

  it "should fail the rake task" do 
    $task_failed.should be_true
  end


end
