require 'spec_helper'

describe 'hyperic::agent', :type => :class do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.4'
    }
  end

  it 'should not normally set up any repos' do
    should_not contain_yumrepo('vfabric-5.3')
  end

  context 'using public vmware repo' do
    let :params do
      { :use_vmware_repo => 'true' }
    end

    it 'should set up the public vfabric yumrepo' do
      should contain_yumrepo('vfabric-5.3').with_enabled('1')
    end
  end

  it 'should install the package' do
    should contain_package('vfabric-hyperic-agent')
    should contain_exec('delete_initial_properties_file')
  end

  it 'should throw some config files around' do
    should contain_file('/etc/init.d/hyperic-hqee-agent').with({
      :ensure => 'file',
      :mode   => '0755',
    })
    should contain_file('/opt/hyperic/hyperic-hqee-agent/conf/agent.properties')
  end

  it 'should run the service' do
    should contain_service('hyperic-hqee-agent').with_ensure('running')
  end

end