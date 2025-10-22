environment     = "dev"
admin_username  = "adminuser"
admin_password  = "Welcome@12345"
vm_size         = "Standard_B2s"
instance_number = "001"
azure_short_location = "eus"
subscription_id = "55b6e4b4-a918-42d4-87b3-762e3fe5e3dd"

global_details = {
  "hub01" = {
    name          = "conneus"
    location      = "eastus"
    address_space = ("10.189.192.0/22")
    subnet        = ("10.189.194.0/26")
    subnet_type   = "intenal"
  }

  "spoke01" = {
    name          = "mgmteus"
    location      = "eastus"
    address_space = ("10.190.192.0/22")
    subnet        = ("10.190.194.0/26")
    subnet_type   = "intenal"
  }

  "spoke02" = {
    name          = "ideneus"
    location      = "eastus"
    address_space = ("10.191.192.0/22")
    subnet        = ("10.191.194.0/26")
    subnet_type   = "intenal"
  }

}
