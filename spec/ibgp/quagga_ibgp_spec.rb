require 'spec_helper'
require 'json'

node_data = JSON.parse(File.read(File.expand_path('../data/quagga.json',__FILE__)))

# Select the data that's specific to this node
target_data = node_data[target]

# Select the data that's specific to this node for the given topology
neighbors = target_data[topology]['neighbors']

# neighbors
describe command("cl-bgp summary") do
  neighbors.each do |neighbor|
    its(:stdout) { should match(/#{neighbor} /) }
  end
end
