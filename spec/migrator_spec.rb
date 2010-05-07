require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/migrator'
require 'albacore/sqlcmd'
describe Migrator do

  before(:each) do
    @cmd = SQLCmd.new
    @cmd.path_to_command = 'C:\Program Files (x86)\Microsoft SQL Server\90\Tools\Binn\sqlcmd.exe'
    @cmd.log_level = :verbose
    @cmd.extend(SystemPatch)
    @cmd.disable_system = true
    @cmd.server="localhost"
    @cmd.database="test"
    @migrate = Migrator.new @cmd
    @migrate.stub_method(:last_run=>1)
  end

  it "should be able to list pending migrations" do
    @migrate.pending.length.should == 2
  end

  describe Migrator, "when running all migrations" do
    before(:each) do
      @migrate.run
    end
    it "should run all pending migrations" do
      @cmd.system_command.should include("-i \"#{@migrate.full_path("002_more.sql")}\"")
      @cmd.system_command.should include("-i \"#{@migrate.full_path("003_even_more.sql")}\"")
    end
  end
  
  it "should get the last migration" do 
    @cmd.query= 'select count(1) from albacore_migrations'
    @cmd.run
    @cmd.result 
  end

end
