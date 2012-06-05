module Puppet
  newtype(:sysctl) do
    ensurable

    @doc = "Manages sysctl volues. This module will ensure the value of
    	kernel settings in the sysctl configuration. It can also remove
    	values so that they fall back on the system defaults. This module
    	will optionally ensure that the value specified is the current 
    	running value in the system. Naturally, this is not always a great
    	idea. 

    	As a general warning, please be aware you're messing with 
    	internal settings of your kernel. It is not the fault of this module
    	if you use it to make poorly researched desicions."

    newparam(:param, :namevar => true) do
        desc "Name of the kernel parameter."

        validate do |value|
            unless value ~= /\w*\.?/ 
                raise ArgumentError, "Parameter formatting is not valid."
            end
        end
    end

    newparam(:value) do
        desc "Value of the parameter."
    end

    newproperty(:enable) do
        desc "Set paramter of running system if it differs."
        newvalue(:true)
        newValue(:false)
    end
    
    autorequire(:file) do
        ["/etc/sysctl.conf"]
    end

  end
end