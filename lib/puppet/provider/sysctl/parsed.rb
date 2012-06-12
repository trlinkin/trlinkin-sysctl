require 'puppet/provider/parsedfile'

sysctl_conf = "/etc/sysctl.conf"

Puppet::Type.type(:sysctl).provide(:parsed,:parent => Puppet::Provider::ParsedFile,
  :default_target => sysctl_conf,:filetype => :flat) do

  #confine :exists => sysctl_conf  # Not sure if confining to this file is smart, by default, mac has one that is ".default"
  commands :sysctl => "sysctl"


  # "Borrowed" from the 'host' type
  text_line :comment, :match => /^#/
  text_line :blank, :match => /^\s*$/


  # define our record line so that the sysctl may be parsed
  record_line :parsed,
              :fields => %w{name value},
              #:optional => %{comment},
              #:match => /^([\w\d_\.\-]+)[\s=:]+(\S+)?$/,
              #:match => /(^\s+#.*)?\n^([\w\d_\.]+)[\s=:]+(\S+)$/,
              :separator => /\s*=\s*/,
              :joiner => '='


    def getparam(param)
      if cmd = Puppet::Util::which('sysctl')
        IO.popen(cmd+" -a") do |list|
          list.each do |line|
            result = line.split(/^([\w\d_\.\-]+)[\s=:]+(\S+)$/)
            return result if result[1] == param
          end
        end
      end
      nil
    end

    def isparam?(param)
      getparam(param)
    end

    def getvalue(param)
      (result = getparam(param)) ? result[2] : nil
    end

    def enable=(value)

      # BSD and Linux/Darwin have a different argument for their sysctl command
      arg = String.new
      arg = '-w' unless Facter.value(:operatingsystem) =~ /bsd/i

      begin
        cmd = [arg,@resource[:name],value]
        output = sysctl(cmd)
      rescue Puppet::ExecutionFailure
        raise Puppet::Error, "Could not set #{@resource[:name]} to #{value}"
      end
    end

end

# @resource.fail
# rescue Puppet::ExecutionFailure