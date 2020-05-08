# DEPRECATED
## This repo is no longer maintained.<br>For a list of current demos, please visit:<br>https://gitlab.com/cumulus-consulting/goldenturtle/<br><br><br>

# cldemo Tests

The [cldemo](https://github.com/CumulusNetworks/cldemo) tests are a set of tests for the various [Cumulus Workbench](http://cumulusnetworks.com/cumulus-workbench/) demos. They can be used to test that the demos are working correctly, or as a basis for writing your own tests for your [Cumulus Linux](http://cumulusnetworks.com/product/overview/) deployments.


## Installing the Tests

The tests are stored together in a single GitHub repository. To use the tests, start by cloning the repository:

`$ git clone https://github.com/CumulusNetworks/cldemo-tests`

Then install the dependencies:

```
$ cd cldemo-tests
$ bundle install
```

## Running the Tests

There are different sets of tests for different demos, as well as a "core" set of tests which are common to every demo. The tests are written in such a way that they also understand and can test the different topologies that are used in the various workbenches. The tests are run using Rake, which is a Make like system for Ruby. To see what tests are available, run the following Rake command to print the list of available targets:

```
$ rake
Usage: rake <tests> <topology> [<target>]

Available tests are: core, ospfunnum
Available topologies are: 2s, 2lt22s
```

For example, `rake ospfunnum 2s` will run the OSPF Unnumbered tests for a 2-switch topology

To run a specific test, simply specify the test name and the topology that the tests should assume. For example, to run the OSPF Unnumbered tests in a 2 switch topology:

`$ rake ospfunnum 2s`

Rake will then run the tests using Serverspec. Serverspec will connect to the remote devices via. SSH and run the tests. Serverspec will print the output, including success or failure, of each test as it runs. A summary is provided at the end:

```
78 examples, 0 failures
All tests passed succesfully
```

By default tests will be run on all of the hosts defined for the given topology. If you wish, you can choose to run the tests for a single target. Simply specify the target; for example:

`$ rake ospfunnum 2s leaf1`

Will run the ospfunnum tests on "leaf1" only.

## Test Structure

The tests are grouped by demo under the 'spec' directory. Tests which are common to all demos are placed under 'core' and demo-specific tests are placed under their own sub-directory. Each file in the directory then contains a series of tests, which are normally somewhat related (E.g. all of the tests for Quagga are in a single file). In order for Serverspec to run the tests, the filename must end in '_spec.rb'.

The available tests (and topologies) are defined in the file `tests.json`

```
{
  "sudo_password": "<redacted>",
  "topologies": ["2s", "2lt22s"],
  "tasks": [
    {
      "name": "core",
      "set": ["core"],
      "targets": {
        "2s": ["leaf1", "leaf2"],
        "2lt22s": ["leaf1", "leaf2", "spine1", "spine2"]
      }
    },
    {
      "name": "ospfunnum",
      "set": ["core", "ospfunnum"],
      "targets": {
        "2s": ["leaf1", "leaf2"],
        "2lt22s": ["leaf1", "leaf2", "spine1", "spine2"]
      }
    }
  ]
}
```

Each task defines a Rake task, along with the list of tests (directories under 'spec') that should be run as part of this target, and data about the switch configuration for the topologies that are valid for each demo. So for example, if the user runs rake ospfunnum 2s, the tests.json file defines the 'ospfunnum' task should run the tests under the 'core' and 'ospfunnum' directories, on both 'leaf1' and 'leaf2'.

## Writing New Tests

Consult the [Serverspec documentation](http://serverspec.org/resource_types.html) for information on the resource types and how to use them.

### Adding New Tests to an Existing Set

Either edit an existing file, or add a new file within the appropriate directory. Provided that the filename ends with '_spec.rb', the tests will be automatically picked up when Serverspec is next run. Note that every file must include the spec_helper.rb file for Serverspec to work correctly:

```
require 'spec_helper'

# Serverspec tests...
```

In some cases, although the tests are common to more than one switch, the actual switch configuration is different. For example, the IP address assigned to a trunk may be different between 'leaf1' and 'leaf2'. In this case, the tests tend to use an external JSON file to provide the actual configuration data, and the tests dynamically select the appropriate data depending on which switch they are running upon. An example of this can be seen in the OSPF Unnumbered tests, `ospfunnum/interface_spec.rb`:

```
require 'spec_helper'
require 'json'

node_data = JSON.parse(File.read(File.expand_path('../data/interfaces.json',__FILE__)))

# Select the data that's specific to this node
target_data = node_data['config'][target]

# ospf unnumbered has same IP on a bunch of devices
for intname in node_data['interfaces'][topology]
  describe interface(intname) do
    it { should have_ipv4_address("#{target_data['local_addr']}/32") }
  end
end
```

```
{
  "interfaces": {
    "2s": ["lo","swp1","swp2","swp3","swp4"],
    "2lt22s": ["lo","swp1","swp2","swp3","swp4","swp17","swp18","swp19","swp20"]
  },
  "config": {
    "leaf1": {
      "local_addr": "10.2.1.1",
      "br0_addr": "10.4.1.1",
      "br1_addr": "10.4.1.129"
    },
    "leaf2": {
      "local_addr": "10.2.1.2",
      "br0_addr": "10.4.2.1",
      "br1_addr": "10.4.2.129"
    },
    "spine1": {
      "local_addr": "10.2.1.3"
    },
    "spine2": {
      "local_addr" : "10.2.1.4"
    }
  }
}
```

In the above code the test selects the local interface address from the JSON according to the hostname. In addition the list of interfaces which are tested differs depending on wether the tests are running on a 2 switch or 2 switch, 2 leaf topology, and this information is also selected programatically.

### Helper Functions

As Serverspec is a Domain Specific Language (DSL) in Ruby, it is perfectly permissible to use standard Ruby Gems or to write your own Ruby code as part of the tests. The cldemo-tests framework provides some additional helper functions which you can use in your tests.

* target - Returns the hostname of the host where the test is currently running E.g. 'leaf1'
* topology - Returns the topology that the tests are being run for E.g. '2s'
* spine? - Returns true if the tests are currently running on a spine switch.
* leaf? - Returns true if the tests are currently running on a leaf switch.
* server? - Returns true if the tests are currently running on a server.

### Adding a New Set

Create a new directory under the 'spec' directory and populate it with your tests (as above). This new set of tests can then either be added to an existing series of tests, or we can create a new task that can be used to run these tests. For example, if we created a new set of tests called 'example', and we wished to add these tests to the 'ospfunnum' tests, we could edit tests.json:

```
{
  "name": "ospfunnum",
  "set": ["core", "ospfunnum", "example"],
  "targets": {
    "2s": ["leaf1", "leaf2"],
    "2lt22s": ["leaf1", "leaf2", "spine1", "spine2"]
  }
}
```

When the user next runs rake ospfunnum 2s or rake ospfunnum 2lt22s, our new tests under the 'example' directory will be run after the tests in the 'ospfunnum' directory.

Instead if we want our tests to be entirely separate from an existing set of tests, we would add an entirely new block to the 'tasks' JSON array:

```
"tasks": [
  {
    "name": "core",
    "set": ["core"],
    "targets": {
      "2s": ["leaf1", "leaf2"],
      "2lt22s": ["leaf1", "leaf2", "spine1", "spine2"]
    }
  },
  ...
  {
    "name": "example",
    "set": ["core", "example"],
    "targets": {
      "2s": ["leaf1", "leaf2"],
      "2lt22s": ["leaf1", "leaf2", "spine1", "spine2"]
    }
  }
]
```

This would add a new target called 'example':

```
$ rake
Usage: rake <tests> <topology> [<target>]

Available tests are: core, ospfunnum, example
Available topologies are: 2s, 2lt22s
```

For example, `rake ospfunnum 2s` will run the OSPF Unnumbered tests for a 2-switch topology

When the user next runs `rake example 2s` or `rake example 2lt22s`, our new tests under the 'example' directory will be run after the tests in the 'core' directory.

---

![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

### Cumulus Linux

Cumulus Linux is a software distribution that runs on top of industry standard 
networking hardware. It enables the latest Linux applications and automation 
tools on networking gear while delivering new levels of innovation and 
ﬂexibility to the data center.

For further details please see: [cumulusnetworks.com](http://www.cumulusnetworks.com)
