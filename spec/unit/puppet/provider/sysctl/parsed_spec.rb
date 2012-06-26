#!/usr/bin/env rspec
require 'puppet'
require 'spec_helper'
require 'shared_behaviours/all_parsedfile_providers'

describe Puppet::Type.type(:sysctl).provider(:parsed) do

  before :each do
    @sysctl_class = Puppet::Type.type(:sysctl)
    @sysctl_instance = @sysctl_class.new(:title => 'fs.file-max')
    @provider_class = @sysctl_class.provider(:parsed)
    @provider_instance = @sysctl_instance.provider
    @provider_instance.stubs(:sysctl).with("fs.file-max").returns("fs.file-max = 365792")
  end

  it "should check if the kernel paramter is valid with the running system" do
    @provider_instance.isparam?('fs.file-max').should == true
  end

  it "should return the running value of the kernel paramter on the system" do
    @provider_instance.getvalue('fs.file-max').should == "365792"
  end

  describe "when parsing a line" do
    before :each do
      @example_line = "fs.file-max = 365792"
    end

    it "should parse the paramter name out of first field" do
      @provider_class.parse_line(@example_line)[:name].should == 'fs.file-max'
    end

    it "should parse the value out of the second field" do
      @provider_class.parse_line(@example_line)[:value].should == '365792'
    end
  end

  describe "on Linux and Mac" do
    it "should have '-w' as a parameter to the sysctl command" do
      Facter.stubs(:value).with(:operatingsystem).returns 'Linux'
      @provider_instance.stubs(:sysctl).with("-w","fs.file-max=365791")
      @provider_instance.enable=('365791')
    end
  end

  describe "on BSD" do
    it "should not have '-w' as a parameter to the sysctl command" do
      Facter.stubs(:value).with(:operatingsystem).returns 'freebsd'
      @provider_instance.stubs(:sysctl).with("","fs.file-max=365791")
      @provider_instance.enable=('365791')
    end
  end
end