require 'spec_helper'

describe command('su hdfs -c "hdfs dfsadmin -report"') do
  its(:stdout) { should match(/server1/) }
  its(:stdout) { should match(/server2/) }
end
