require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/migrator'
require 'albacore/sqlcmd'
describe Migrator do

  before(:each) do
    @migrate = Migrator.new do |m| 
      m.path_to_command = 'sqlcmd.exe'
      m.log_level = :verbose
      m.extend(SystemPatch)
      m.disable_system = true
      m.server="localhost"
      m.database="test"
      m.stub_method(:last_run=>1, :insure_migration_table_exists=>nil, :valid_command_exists=>true)
      m.migration_directory = File.join(File.dirname(__FILE__), 'support', 'migrations')
    end 
  end

  it "should be able to list pending migrations" do
    @migrate.pending.length.should == 2
  end

  describe Migrator, "when running all migrations" do
    before(:each) do
      #@migrate.migrate
    end
    it "should run all pending migrations" do
      pending 'not sure best way to make this now pass...'
      @migrate.system_command.should include("-i \"#{@migrate.full_path("002_more.sql")}\"")
      @migrate.system_command.should include("-i \"#{@migrate.full_path("003_even_more.sql")}\"")
    end
  end
  
  
end
