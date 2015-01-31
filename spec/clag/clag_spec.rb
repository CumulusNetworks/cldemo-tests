require 'spec_helper'

describe file('/etc/default/clagd') do
    it { should be_file }
end

describe service('clagd') do
    it { should be_running }
end

describe command('clagctl') do
    its(:stdout) { should match(/The peer is alive/) }
end
