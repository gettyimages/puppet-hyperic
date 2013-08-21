# Class: hyperic::agent
#
#
class hyperic::agent (
  $use_vmware_repo      = hiera('hyperic::agent::use_vmware_repo', false),
  $setup_server         = hiera('hyperic::agent::setup_server', 'localhost'),
  $setup_port           = hiera('hyperic::agent::setup_port', '7080' ),
  $setup_sslport        = hiera('hyperic::agent::setup_sslport', '7443'),
  $setup_login          = hiera('hyperic::agent::setup_login', 'hqadmin'),
  $setup_password       = hiera('hyperic::agent::setup_password', 'hqadmin'),
  $setup_unidirectional = hiera('hyperic::agent::setup_unidirectional', 'No'),
  $setup_secure         = hiera('hyperic::agent::setup_secure', 'Yes'),
  $setup_ip             = hiera('hyperic::agent::setup_ip', '*default*'),
  $setup_port           = hiera('hyperic::agent::setup_port', '*default*'),
  $setup_resetuptoken   = hiera('hyperic::agent::setup_resetuptoken', 'no'),
  $setup_unverifiedcerts = hiera('hyperic::agent::setup_unverifiedcerts', 'yes'),
  $java_home            = hiera('hyperic::agent::java_home', '/usr/lib/jvm/jre'),
  $unix_jdk_package     = hiera('hyperic::agent::unix_jdk_package', 'java-1.7.0-openjdk-devel'),
) {

  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {

    if $use_vmware_repo {

      $yumrepo_url = $::operatingsystemrelease ? {
        /6.?/ => 'http://repo.vmware.com/pub/rhel6/vfabric/5.3/$basearch',
        /5.?/ => 'http://repo.vmware.com/pub/rhel5/vfabric/5.3/$basearch',
      }

      yumrepo { 'vfabric-5.3':
        baseurl  => $yumrepo_url,
        descr    => 'VMware vFabric 5.3 - $basearch',
        enabled  => '1',
        gpgcheck => '0',
      }

      Yumrepo['vfabric-5.3'] -> Package['vfabric-hyperic-agent']
    }

    package { 'vfabric-hyperic-agent':
      ensure => installed,
    }

    # clear out the rpm's copy of this file so we can drop ours in
    exec { 'delete_initial_properties_file':
      command     => '/bin/rm -f /opt/hyperic/hyperic-hqee-agent/conf/agent.properties',
      refreshonly => true,
      onlyif      => '/usr/bin/test ! -f /opt/hyperic/hyperic-hqee-agent/conf/agent.scu',
    }

    if ! defined(Package[$unix_jdk_package]) {
      package { $unix_jdk_package:
        ensure => installed,
      }
    }

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
      owner   => hyperic,
      group   => vfabric,
      mode    => '0644',
      content => template("${module_name}/agent.properties.erb"),
    }

    service { 'hyperic-hqee-agent':
      ensure  => running,
    }

    #Relationships
    Package[$unix_jdk_package]                                    ->  Package['vfabric-hyperic-agent']
    Package['vfabric-hyperic-agent']                              ->  File['/etc/init.d/hyperic-hqee-agent']
    Package['vfabric-hyperic-agent']                              ~>  Exec['delete_initial_properties_file']
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