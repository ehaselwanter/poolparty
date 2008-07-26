require File.dirname(__FILE__) + '/../../spec_helper'

describe "String" do
  before(:each) do
    @str =<<-EOS
      echo 'hi'
      puts 'hi'
    EOS
  end
  it "should be able to convert a big string with \n to a runnable string" do
    @str.runnable.should == "echo 'hi' &&       puts 'hi'"
  end
end