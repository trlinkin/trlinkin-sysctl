module Puppet
  newtype(:sysctl) do

    @doc = "Manages sysctl values. This module will ensure the value of
      kernel settings in the sysctl configuration. It can also remove
      values so that they fall back on the system defaults. This module
      will optionally ensure that the value specified is the current 
      running value in the system. Naturally, this is not always a great
      idea. 

      As a general warning, please be aware you are modifying the internal 
      settings of your kernel, possibly during runtime! It is not the 
      fault of this type if you use it to make poorly researched decisions."


    ensurable do
      self.defaultvalues

      # This is a compromise. We're checking the name parameter with the system here
      # because the default provider is not set until after the name parameter
      # processes its value. We only want to validate with the running system if we're 
      # applying running values, or ensuring present. I don't see why we should not be 
      # able to ensure absent a value that is invalid on the system, it may come in handy
      # some day.
      validate do |value|
        valid = super(value)
        provider.isparam?(resource[:name]) if value.to_s == 'present' || resource[:enable].to_s == 'true'

        valid
      end

      def sync
        event = super()

        # This is a hack taken from the Service type. There are plans that one
        # day may make this unnecessary. For now, it ensures that the enable 
        # property is kept in sync even when the ensure resource is not in sync.
        # The current drawback is that the event will not be reported.
        if property = resource.property(:enable)
          val = property.retrieve
          property.sync unless property.safe_insync?(val)
        end

        event
      end
    end

    newparam(:name) do
      desc "Name of the kernel parameter."

      isnamevar

      validate do |value|
        unless value =~ /^[\w\d_\.\-]+$/ 
          raise ArgumentError, "kernel parameter formatting is not valid."
        end
      end
    end

    newproperty(:target) do
      desc "The file in which to store sysctl information. Only used when 
        saving changes to disk. Defaults to `/etc/sysctl.conf`. Some newer
        distribution of Linux now support a `sysctl.d` directory."

      defaultto { 
        if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
          @resource.class.defaultprovider.default_target
        else
          nil
        end
      }
    end

    newproperty(:value) do
      desc "Value the kernel parameter should be set to."

      defaultto 0
    end

    newproperty(:enable) do
      desc "Enable new Kernel parameter value on running system."

      # since puppet is a declarative language, it makes sense to allow this property to be set 
      # to 'false' so users can be very explicit with their resource declarations
      newvalue (:true)
      newvalue (:false)

      defaultto :false

      munge do |value|
        value = value.to_s.intern
        value == :true ? resource.property(:value).should.tr("\t","\s") : value
      end

      def retrieve
        provider.getvalue(resource[:name])
      end

      def insync?(is)
        return true if should == :false
        is.tr!("\t","\s")
        super
      end

      def change_to_s(current_value, newvalue)
        return "modified running value of '#{resource[:name]}' from #{self.class.format_value_for_display is_to_s(current_value)} to #{self.class.format_value_for_display should_to_s(newvalue)}"
      end
    end
    
    autorequire(:file) do
      ["/etc/sysctl.conf"]
    end

  end
end
