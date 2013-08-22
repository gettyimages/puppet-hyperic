#puppet-hyperic
==============
[![Build Status](https://travis-ci.org/curator/puppet-hyperic.png)](https://travis-ci.org/curator/puppet-hyperic)

####Table of Contents

1. [Overview - What is the Hyperic module?](#overview)


##Overview
The vFabric Hyperic module allows you to install and configure the vFabric Hyperic agent with minimal effort.

##Setup/Example

### Default (basic default, best used with hiera to provide data)

`  include hyperic::agent`

### Slightly more complicated

`  class { 'hyperic::agent':
    use_vmware_repo =>  true,
    setup_server    =>  'hyperic.server.local',
    java_home       =>  '/usr/java/latest,
`  }