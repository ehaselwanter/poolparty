require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/poolparty/helpers/binary'

describe "Binary" do
  before(:each) do
    Dir.stub!(:[]).and_return %w(init console)
  end
  it "should have the binary location set on Binary" do
    Binary.binary_directory.should =~ /lib\/poolparty\/helpers\/\.\.\/\.\.\/\.\.\/bin/
  end
  it "should be able to list the binaries in the bin directory" do
    Binary.available_binaries_for("pool").should == %w(console init)
  end
  it "should be able to say the binary is in the binary_directory" do
    Binary.available_binaries_for("pool").include?("console")
  end
  describe "get_existing_spec_location" do
    before(:each) do
      ::File.stub!(:readable?).and_return false
      ::File.stub!(:readable?).with("/etc/poolparty/clouds.rb").and_return true
    end
    it "should be a String" do
      Binary.get_existing_spec_location.class.should == String
    end
  end
end