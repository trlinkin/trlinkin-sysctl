module Puppet
  newtype(:sysctl) do

    @doc = "Manages sysctl values. This module will ensure the value of
      kernel settings in the sysctl configuration. It can also remove
      values so that they fall back on the system defaults. This module
      will optionally ensure that the value specified is the current 
      running value in the system. Naturally, this is not always a great
      idea. 

      As a general warning, please be aware you're messing with internal 
      settings of your kernel, possibly during runtime! It is not the 
      fault of this type if you use it to make poorly researched decisions."


    ensurable do
      self.defaultvalues
      def retrieve
        # This check is here since the provider won't be associated with the type 
        # when it first is validating the input variables.
        provider.isparam?(resource[:name])
        super
      end

      def sync
        event = super()

        # This is a hack taken from the Service type. There are plans that one
        # day may make this uneccessary. For now, it ensures that the enable 
        # property is kept in sync even when the ensure resource is not in sync.
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

    newproperty(:value) do
      desc "Value the kernel parameter should be set to."
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

    newproperty(:enable) do
      desc "Enable new Kernel parameter value on running system."

      # since puppet is a declarative language, it makes sense to allow this property to be set 
      # to 'false' so users can be very explicit with their resource declarations
      newvalue(:true)
      newvalue(:false)
      defaultto :false

      def retrieve
        provider.getvalue(resource[:name])
      end

      def insync?(is)
        return true if should == :false

        # Here we disable the validation to allow us to set our @should to that of the value property.
        # The reason I'm overriding this function is because the original user provided value has already
        # been validated. The value of the :value parameter is left to the user to provied a safe value.
        def self.validate(value); true; end

        # ... and here we set the value.
        resource[:enable] = resource.should(:value) if should == :true
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
