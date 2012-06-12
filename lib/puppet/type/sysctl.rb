module Puppet
  newtype(:sysctl) do

    @doc = "Manages sysctl volues. This module will ensure the value of
      kernel settings in the sysctl configuration. It can also remove
      values so that they fall back on the system defaults. This module
      will optionally ensure that the value specified is the current 
      running value in the system. Naturally, this is not always a great
      idea. 

      As a general warning, please be aware you're messing with internal 
      settings of your kernel, possibly durring runtime!. It is not the 
      fault of this type if you use it to make poorly researched desicions."


    ensurable do
      self.defaultvalues
      def retrieve
        self.fail("Cannot find kernel paramter '#{resource[:name]}' on system.") if not provider.isparam?(resource[:name])
        super
      end
    end

    newparam(:name) do
      desc "Name of the kernel parameter."

      isnamevar

      validate do |value|
        unless value =~ /^[\w\d_\.\-]+$/ 
          raise ArgumentError, "Kernel parameter formatting is not valid."
        end
      end
    end

    newproperty(:value) do
      desc "Value of the kernel parameter."
    end

    #newproperty(:comment) do
    #  desc "A comment that will be placed above the line with a # character."
    #end

    newproperty(:target) do
      desc "The file in which to store sysctl information. Only used when 
        saving changes to disk. Defaults to `/etc/sysctl.conf`. Some newer
        distrobutions of Linux now support a `sysctl.d` directory."

      defaultto { 
        if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
          @resource.class.defaultprovider.default_target
        else
          nil
        end
      }
    end

    newproperty(:enable) do
      desc "Enable new Kernel paramter value on running system."

      newvalue(:true)

      newvalue(:false)

      defaultto :false

      def retrieve
        self.fail("Cannot find kernel paramter '#{resource[:name]}' on system.") if not provider.isparam?(resource[:name])
        provider.getvalue(resource[:name])
      end

      def insync?(is)
        return true if should == :false

        def self.validate(value)
          return
        end

        resource[:enable] = resource[:value] if should == :true
        puts should
        super        
      end
    end
    
    autorequire(:file) do
      ["/etc/sysctl.conf"]
    end
  end
end
