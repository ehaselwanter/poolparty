require File.dirname(__FILE__) + '/spec_helper'

describe "remote instance" do
  before(:each) do
    @instance = RemoteInstance.new({:ip => "127.0.0.1"})
    stat = { 'cpu' => "0.1", 'memory' => "0.1", 'web' => "110.0" }
    @instance.stub!(:status).and_return(stat)
  end
  
  describe "in general" do
    it "should set the ip upon creation" do
      @instance.ip.should == "127.0.0.1"
    end
    it "should be able to tell it's cpu status" do
      @instance.cpu.should == 0.1
    end
    it "should be able to tell it's web status" do
      @instance.web.should == 110.0
    end
    it "should be able to tell it's memory status" do
      @instance.memory.should == 0.1
    end
  end  
  
  describe "when handling proxy requests" do
    before(:each) do
      @mock_http = mock("http")
      Application.stub!(:client_port).and_return(7788)
      
      Net::HTTP.stub!(:start).and_yield @mock_http            
      
      @req = Rack::MockRequest.env_for("http://127.0.0.1:7788/")
      @response = Rack::Response.new
      @mock_http.stub!(:request).and_return( @response.finish )
      
      @instance.stub!(:ip).and_return("http://127.0.0.1")
    end
    it "should respond to process call" do
      p @instance.process("/", @req)
    end
  end
end

describe "in groups" do
  before(:each) do
    @instances = []
    @stats = []
    3.times {|i|
      i += 1
      inst = RemoteInstance.new({:ip => "127.0.0.#{i}"})
      stat = { 'cpu' => "0.#{i}", 'memory' => "0.#{i}", 'web' => "1#{i}0.0" }
      inst.stub!(:status).and_return(stat)
      @instances << inst
      @stats << stat
    }
  end
  it "should check the status of the instance when sorting the instances" do
    @instances[0].should_receive(:status).at_least(1).times.and_return(@stats[0])
    @instances.sort
  end
  it "should create a status based off the previous one" do
    (@instances[0].status_level < @instances[1].status_level).should == true
  end
end