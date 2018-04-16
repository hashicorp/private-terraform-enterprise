# The vSphere server hostname or IP to connect to. Example: "vsphere.customer.com"
vsphere_server = ""

# The name of the datacenter you will be deploying pTFE into. Example: "DC1"
dc_name = ""

# The name of the datastore you want to use. Example: "datastore1". Comment this line out if you use datastore clusters
datastore_name = ""

# If you use datastore clusters (RDS) please use this variable instaed of datastore_name
#datastore_cluster_name = ""

# Comment out if you do not use resource pools if you use resource pools
resourcepool_name = ""

# The name of the vm network where you want to deploy pTFE. Example "VM Network".
network_name = ""

# The name of the template you will use as a base for pTFE. Example "ubuntu_template".
template_name = ""

# The name of the pTFE host, without the domain. Example: "ptfe"
hostname = ""

# The domain mame of the pTFE server. Example: "customer.com"
domain = "hashicorp-success.com"

# The IP Address of the server. Example: "10.0.0.100"
ipaddress = ""

# The netmask of the server. Example: "24"
netmask = ""

# The Gateway address of the server. Example: "10.0.0.1"
gateway = ""

# DNS Servers to use. Example: ["1.1.1.1","1.0.0.1"]
dns = [""]

# Path to the settings json on the system you are running this from. Default location is the application-install subfolder.
json_location = "application-install/settings.json"

# Path to the replicated.conf file on the system you are running this from. Default location is the application-install subfolder.
replicated_conf = "application-install/replicated.conf"

# Path to the license file on the system you are running this from. Default location is the application-install subfolder.
license = "application-install/amy.rli"