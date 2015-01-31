require 'spec_helper'

describe service('ptmd') do
  it { should be_running }
end

describe file('/etc/ptm.d/topology.dot') do
  it { should be_file }
end

# at least one pass
describe command("ptmctl") do
  its(:stdout) { should match(/pass /) }
end

# no fails!
describe command("ptmctl") do
  its(:stdout) { should_not match(/fail /) }
end
