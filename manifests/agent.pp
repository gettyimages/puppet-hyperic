# Class: hyperic::agent
#
#
class hyperic::agent (
  $use_vmware_repo        = false,
  $setup_camip            = 'localhost',
  $setup_camport          = '7080' ,
  $setup_camsslport       = '7443',
  $setup_login            = 'hqadmin',
  $setup_password         = 'hqadmin',
  $setup_unidirectional   = 'No',
  $setup_secure           = 'Yes',
  $setup_agentip          = '*default*',
  $setup_agentport        = '*default*',
  $setup_resetuptokens    = 'no',
  $setup_unverifiedcerts  = 'yes',
  $java_home              = '/usr/lib/jvm/jre',
  $unix_jdk_package       = 'java-1.7.0-openjdk-devel',
  $vfabric_version        = '5.3',
  $agent_user             = 'hyperic',
  $agent_group            = 'vfabric',
  $hyperic_package_name   = 'vfabric-hyperic-agent', # Change to vcenter-hyperic-agent in newer versions
) {

  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {

    if $use_vmware_repo {

      $yumrepo_url = $::operatingsystemrelease ?vfabric/$ {
        /6.?/ => "http://repo.vmware.com/pub/rhel6/{vfabric_version}/\$basearch",
        /5.?/ => "http://repo.vmware.com/pub/rhel5/vfabric/${vfabric_version}/\$basearch",
      }

      yumrepo { "vfabric-${vfabric_version}":
        baseurl  => $yumrepo_url,
        descr    => "VMware vFabric ${vfabric_version} - \$basearch",
        enabled  => '1',
        gpgcheck => '0',
      }

      Yumrepo["vfabric-${vfabric_version}"] -> Package[$hyperic_package_name]
    }

    package { $hyperic_package_name:
      ensure => installed,
    }

    # clear out the rpm's copy of this file so we can drop ours in
    exec { 'delete_initial_properties_file':
      command     => '/bin/rm -f /opt/hyperic/hyperic-hqee-agent/conf/agent.properties',
      refreshonly => true,
      onlyif      => '/usr/bin/test ! -f /opt/hyperic/hyperic-hqee-agent/conf/agent.scu',
    }

    ensure_packages([$unix_jdk_package])

    file { '/etc/init.d/hyperic-hqee-agent':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0755',
      content => template("${module_name}/hyperic-hqee-agent.init.redhat.erb"),
    }

    file { '/opt/hyperic/hyperic-hqee-agent/conf/agent.properties':
      ensure  => file,
      replace => false,
      owner   => $agent_user,
      group   => $agent_group,
      mode    => '0644',
      content => template("${module_name}/agent.properties.erb"),
    }

    # ensure permissions are correct
    exec { "set_permissions":
      command  => "/bin/chown -R ${agent_user}:${agent_group} /opt/hyperic",
      require  => [ File["/opt/hyperic/hyperic-hqee-agent/conf/agent.properties"],
                   Package["vfabric-hyperic-agent"] ]
    }

    service { 'hyperic-hqee-agent':
      ensure  => stopped,
      require  => Exec["set_permissions"]
    }

    #Relationships
    Package[$unix_jdk_package]                                    ->  Package[$hyperic_package_name]
    Package[$hyperic_package_name]                                ->  File['/etc/init.d/hyperic-hqee-agent']
    Package[$hyperic_package_name]                                ~>  Exec['delete_initial_properties_file']
    Exec['delete_initial_properties_file']                        ->  File['/opt/hyperic/hyperic-hqee-agent/conf/agent.properties']
    File['/etc/init.d/hyperic-hqee-agent']                        ~>  Service['hyperic-hqee-agent']
    File['/opt/hyperic/hyperic-hqee-agent/conf/agent.properties'] ~>  Service['hyperic-hqee-agent']

  } elsif $::osfamily == 'windows' {
    warning('Windows support may be coming soon.  Feel free to add it.')
  } elsif $::osfamily == 'debian' {
    warning('Debian/Ubuntu support may be coming soon.  Feel free to add it.')
  } else {
    warning("Unsupported osfamily ${::osfamily}.")
  }

}
