require File.dirname(__FILE__) + '/../../../spec_helper'




describe "VbCapistrano" do
  before(:each) do
    @tr = PoolParty::Vb::VbCapistrano.new
  end

  it "get vm list" do
    @tr.run_ls.should.include("ls")
  end

end