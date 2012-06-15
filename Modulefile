name    'trlinkin-sysctl'
version '0.0.1'
source 'UNKNOWN'
author 'Thomas Linkin'
license 'Apache License, Version 2.0'
summary 'Control Sysctl entries on UNIX systems.'
description 'This module adds a sysctl type and provider 
to Puppet. This module is designed to control sysctl on Linux,
Mac, and BSD. This type will control the /etc/sysctl.conf file 
as well as optionally enable the new sysctl value on the running
system.

The type has 5 parameters: ensure, enable, name, value, target.

ensure
	Primary property controlling the state the resource should be in. Valid values are :present, and :absent.

name
	Name of the kernel parameter. The parameter must exist on the system for the resource to work.

value
	Value of the kernel parameter.

enable
	Whether or not to enable the kernel parameter on the live running system. This will use the value set
	in the value property. This option will be honored if the resource is set to present. Valid values are 
	:true, and :false. The default value is :false, and has no effect.

target
	Location to manage sysctl entries at. Defaults to /etc/sysctl.conf and will create the file is necessary.'


project_page 'https://github.com/trlinkin/trlinkin-sysctl'

## Add dependencies, if any:
