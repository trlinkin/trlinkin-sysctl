require 'puppet/provider/parsedfile'

sysctl_conf = "/etc/sysctl.conf"

Puppet::Type.type(:sysctl).provide(:sysctl,:parent => Puppet::Provider::ParsedFile,
  :default_target => sysctl_conf,:filetype => :flat) do

  #confine :exists => sysctl_conf  # Not sure if confining to this file is smart, by default, mac has one that is .default
  commands :sysctl => "sysctl"


  # "Borrowed" from the 'host' type
  text_line :comment, :match => /^#/
  text_line :blank, :match => /^\s*$/


  # define our record line so that the sysctl may be parsed
  record_line :parsed,
              :fields     => %W{comment param value},
              :optional   => %{comment}
              :match      => /(^\s+#.*)?\n^([\w\d_\.]+)[\s=:]+(\S+)$/,
              :post_parse => proc { |hash|
                # Again, the 'host' type was used as an example here...
                # An absent comment should match "comment => ''"
                hash[:comment] = '' if hash[:comment].nil? or hash[:comment] == :absent
              }
              :to_line    => proc { |hash|
                [:param, :value].each do |key|
                  raise ArgumentError, "#{key} is a require attribut for sysctl" unless hash[key] and hash[key] != absent
                end

                # BSD and Linux/Darwin have a different style for their sysctl.conf entries
                os = Facter.value(:operatingsystem)
                case
                when os =~ /bsd/i
                  delim = ": "
                else
                  delim = " = "
                end

                str = ""
                if hash.include?(:comment) and !hash[:comment].empty?
                  str = "##{hash[:comment]}\n"
                end
                str += "#{hash[:param:]}#{delim}#{hash[:value]}"
                str
              }

    def getparam(param)
      if cmd = Puppet::Util::which('sysctl')
        IO.popen(cmd+" -a") do |list|
          list.each do |line|
            result = line.split(/^([\w\d_\.]+)[\s=:]+(\S+)$/)
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
      if getparam(param)

      end
    end

end

# @resource.fail