require 'spec_helper'

describe file('/etc/cumulus/.license.txt') do
  it { should be_file }
end

describe command('/usr/cumulus/bin/cl-license') do
  its(:stdout) { should match(/email=/) }
  its(:stdout) { should match(/account=/) }
  its(:stdout) { should match(/expires=/) }
  its(:stdout) { should match(/serial=/) }
  its(:stdout) { should match(/num_licenses=/) }
  its(:stdout) { should match(/need_eula=0/) }
  its(:stdout) { should match(/BEGIN PGP SIGNED MESSAGE/) }
  its(:stdout) { should match(/BEGIN PGP SIGNATURE/) }
  its(:stdout) { should match(/END PGP SIGNATURE/) }
end
