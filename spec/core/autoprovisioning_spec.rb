require 'spec_helper'

describe file('/var/lib/cumulus/autoprovision.conf') do
  it { should be_file }
end
