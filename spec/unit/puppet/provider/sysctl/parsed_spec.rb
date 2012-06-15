#!/usr/bin/env rspec
require 'puppet'
require 'spec_helper'
require 'shared_behaviours/all_parsedfile_providers'

describe Puppet::Type.type(:sysctl).provider(:parsed) do

  it "should parse the value out of the sysctl command output" do
  end

  it "should validate if a kernel paramter exists on the system" do
  end

  describe "when parsing a line" do
    before :each do
      @example = "fs.file-max = 365792"
    end

    it "should parse the paramter name out of first field" do
    end

    it "should parse the value out of the second field" do
    end
  end

  describe "on Linux and Mac" do
    it "should have '-w' as a parameter to the sysctl command"
    end
  end

  describe "on BSD" do
    it "should not have '-w' as a parameter to the sysctl command"
    end
  end
end