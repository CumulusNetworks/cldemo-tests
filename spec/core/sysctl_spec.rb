require 'spec_helper'

describe command("sysctl -n net.ipv4.conf.all.arp_filter") do
  its(:stdout) { should match(/0/) }
end
