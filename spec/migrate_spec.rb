require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/migrate'
describe "migrate" do

  it "should be able to list pending migrations" do
    migrate = Migrate.new
    migrate.stub_method(:last_run=>1)
    migrate.pending.length.should == 2
  end

  it "should run all pending migrations" do
    pending
  end

end
