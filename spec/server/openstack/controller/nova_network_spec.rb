require 'spec_helper'

cmdnova = "/usr/bin/nova --os-username admin --os-password adminpw  --os-tenant-name admin --os-auth-url http://192.168.0.201:35357/v2.0"

describe command(cmdnova + " network-list") do
  its(:exit_status) { should eq(0) }
end

describe command(cmdnova + " network-list") do
  its(:stdout) { should match(/10.10.1.0/) }
end

for svcname in ["nova-network"] do
  describe service(svcname) do
    it { should be_enabled }
    it { should be_running }
  end
end
