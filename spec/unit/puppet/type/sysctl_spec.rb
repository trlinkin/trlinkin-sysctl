require 'puppet'
require 'puppet/type/sysctl'

describe Puppet::Type.type(:sysctl) do

  before :each do
    @sysctl = Puppet::Type.type(:sysctl).new()
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