require 'spec_helper_system'

describe 'basic tests:' do

  # Using puppet_apply as a helper
  it 'hyperic::agent class should work with no errors' do
    pp = <<-EOS
      class { 'hyperic::agent': use_vmware_repo => true }
    EOS

    # Run it twice and test for idempotency
    puppet_apply(pp) do |r|
      r.exit_code.should_not == 1
      r.refresh
      r.exit_code.should be_zero
    end
  end

end