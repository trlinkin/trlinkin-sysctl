require 'puppet'
require 'puppet/type/sysctl'

describe Puppet::Type.type(:sysctl), "when validating attributes" do

  it "should have a #{param} parameter" do
    Puppet::Type.type(:stsctl).attrtype(:name).should == :param
  end

  [:ensure, :value, :target, :enable].each do |param|
    it "should have an #{param} property" do
      Puppet::Type.type(:sysctl).attrtype(param).should == :property
    end
  end
end

describe Puppet::Type.type(:sysctl) do

  before :each do
    @sysctl = Puppet::Type.type(:sysctl).new(:name => 'fs.file-max', :ensure => :present, :value => 365791, :enable => :true)
  end

  it "should validate the name parameter when :ensure is set to present" do

  end

  it "should validate the formatting of the :name" do

  end

  it "should not find :enable in sync when value is :false" do

  end

  it "should set enable to the value of :value when :enable is :true" do

  end
end