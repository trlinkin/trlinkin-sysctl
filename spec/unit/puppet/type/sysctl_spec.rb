require 'spec_helper'

describe Puppet::Type.type(:sysctl), "when validating attributes" do

  it "should have a name parameter" do
    Puppet::Type.type(:sysctl).attrtype(:name).should == :param
  end

  [:ensure, :value, :target, :enable].each do |param|
    it "should have an #{param} property" do
      Puppet::Type.type(:sysctl).attrtype(param).should == :property
    end
  end
end

describe Puppet::Type.type(:sysctl), "when validating attribute values" do

  it "should validate the formatting of the :name paramter" do
    Puppet::Type.type(:sysctl).new(:name => 'fs.file-max')
  end

  it "should support :true as a value for :enable" do
    Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :enable => true )
  end

  it "should support :false as a value for :enable" do
    Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :enable => false )
  end
end

describe Puppet::Type.type(:sysctl), "when setting default attribute values" do

  it "should have a default value of '/etc/sysctl.conf' for :target" do
    sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max')
    sysctl[:target].should == '/etc/sysctl.conf'
  end

  it "should default to a value of :false for :enable" do
    sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max')
    sysctl[:enable].should == :false
  end

  it "should default to 0 as the value for the :value property" do
    sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max')
    sysctl[:value].should == 0
  end
end

describe Puppet::Type.type(:sysctl), "when retrieving the host's current state" do

  it "should check with the provider for the current running value of the kernel parameter" do
    sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :enable => :true)
    sysctl.provider.expects(:getvalue).with('fs.file-max').returns(:foo)
    sysctl.property(:enable).retrieve.should == :foo
  end
end

describe Puppet::Type.type(:sysctl), "when checking if properties are in sync" do

  it "should find :enable in sync when the provided value is :false" do
    sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :enable => :false)
    sysctl.property(:enable).insync?(:foo).should == true
  end
end

describe Puppet::Type.type(:sysctl), "when changing the host" do
  before :each do
    @sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :ensure => :present, :value => 365791, :enable => :true)
  end

  it "should change the kernel paramter's running state if it does not match what was provided to the :value property" do
  end

  it "should sync the service's enable state when changing the state of :ensure if :enable is set to :true" do
  end

end
