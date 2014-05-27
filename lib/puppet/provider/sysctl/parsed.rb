require 'puppet/provider/parsedfile'

sysctl_conf = "/etc/sysctl.conf"

Puppet::Type.type(:sysctl).provide(:parsed,:parent => Puppet::Provider::ParsedFile,
  :default_target => sysctl_conf,:filetype => :flat) do

  #confine :exists => sysctl_conf  # Not sure if confining to this file is possible, by default, mac only has "/etc/sysctl.conf.default"
  commands :sysctl => "sysctl"


  text_line :comment, :match => /^#/
  text_line :blank, :match => /^\s*$/


  # define our record line so that the sysctl may be parsed
  record_line :parsed,
              :fields => %w{name value},
              :separator => /\s*=\s*/,
              :joiner => '='

    def getparam(param)
      begin
        output = sysctl(param)
        result = output.split(/^([\w\d_\.\-]+)\s*[=:]\s*(.*)$/)
        return result if result[1] == param
      rescue Puppet::ExecutionFailure
        nil
      end
      nil
    end

    def isparam?(param)
      @resource.fail "Cannot find kernel parameter '#{param}' on system." unless getparam(param)
      true
    end

    def getvalue(param)
      (result = getparam(param)) ? result[2] : nil
    end

    def enable=(value)

      # BSD and Linux/Darwin have a different argument for their sysctl command
      arg = String.new
      arg = '-w' unless Facter.value(:operatingsystem) =~ /bsd/i

      begin
        cmd = [arg,"#{@resource[:name]}=#{value}"]
        output = sysctl(*cmd)
      rescue Puppet::ExecutionFailure
        raise Puppet::Error, "Could not set #{@resource[:name]} to #{value}"
      end
    end
end
