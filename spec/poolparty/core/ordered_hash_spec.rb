require File.dirname(__FILE__) + '/../spec_helper'

describe "Ordered Hash" do
  before(:each) do
    @oh = OrderedHash.new
    @oh["var1"] = 10
    @oh["var2"] = 2
    @oh[:var3] = 3
    @oh["var4"] = 4
  end
  it "should stay in order in enumeration (keys)" do
    @oh.collect {|k,v| k }.should == ["var1", "var2", :var3, "var4"]
  end
  it "should stay in order in enumeration (values)" do
    @oh.collect {|k,v| v }.should == [10,2,3,4]
  end
  it "should be able to be pulled out with the hash convention" do
    @oh['var1'].should == 10
    @oh['var2'].should == 2
    @oh[:var3].should == 3
    @oh["var4"].should == 4
  end
  it "should retain order in a merge" do
    @oh.merge!(:var5 => 5)
    @oh.collect {|k,v| v }.should == [10,2,3,4,5]
  end
  it "should retain order in a non-descructive merge" do
    @oh = @oh.merge(:var5 => 5)
    @oh.collect {|k,v| v }.should == [10,2,3,4,5]
  end
  it "should keep the keys in order too!" do
    @oh.keys.should == ["var1", "var2", :var3, "var4"]
  end
  it "should have values method" do
    @oh.values.should === [10,2,3,4]
  end
  it "should to_json" do
    @oh[:arr] = [1,2,3]
    @oh.to_json.should == "{\"var1\":10,\"var2\":2,\"var3\":3,\"var4\":4,\"arr\":[1,2,3]}"
  end
  it "PoolParty Key" do
      @oh[:key] = [Key.new, Key.new('path/to/nowhere')]
      expected=<<JSO
 {\"var1\":10,\"var2\":2,\"var3\":3,\"var4\":4,\"key\":[{\"basename\":\"id_rsa\",\"full_filepath\": \"/etc/poolparty/id_rsa\"},{\"basename\":\"path/to/nowhere\",\"full_filepath\": \"/etc/poolparty/path/to/nowhere\"}]}
JSO
      @oh.to_json.should == expected.strip
  end
end