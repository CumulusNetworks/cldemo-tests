require 'spec_helper'

glancecmd = "/usr/bin/glance  --os-username=admin --os-password=adminpw --os-tenant-name=admin --os-auth-url=http://192.168.0.201:35357/v2.0"

describe command(glancecmd + " image-list") do
  its(:exit_status) { should eq(0) }
end

describe command(glancecmd + " image-list") do
  its(:stdout) { should match(/Cirros/) }
end

