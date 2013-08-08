# == Class: sysctl
#
# Simple management of /etc/sysctl.conf
#
# === Examples
#
# include sysctl
#
# === Authors
#
# Thomas Linkin <trlinkin@gmail.com>
#
# === Copyright
#
# Copyright 2011 Thomas Linkin, unless otherwise noted.
#
class sysctl {

  file { '/etc/sysctl.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

}
