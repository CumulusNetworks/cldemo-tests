require 'spec_helper'

describe command("yarn node -list -states RUNNING") do
  its(:stdout) { should match(/server1/) }
  its(:stdout) { should match(/server2/) }
end
