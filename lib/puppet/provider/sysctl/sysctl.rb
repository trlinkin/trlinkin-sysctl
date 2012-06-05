
sysctl_conf = "/etc/sysctl.conf"

Puppet::Type.type(:sysctl).provide(:sysctl,:parent => Puppet::Provider::ParsedFile,
  :default_target => sysctl_conf,:filetype => :flat) do
  confine :exists => sysctl_conf

  commands :sysctl => "sysctl"

end