variable "rancher_api_url" {
  default     = ""
  description = "Rancher API endpoint to manager your Harvester cluster"
}

variable "rancher_access_key" {
  default     = ""
  description = "Rancher access key"
}

variable "rancher_secret_key" {
  default     = ""
  description = "Rancher secret key"
}

variable "rancher_insecure" {
  default     = false
  description = "Allow insecure connections to the Rancher API"
}

variable "ssh_key" {
  default     = ""
  description = "SSH key to use for the Harvester cluster"
  
}

variable "project_name" {
  default     = "test"
  description = "Name of the project to create the Harvester cluster"
  
}

variable "node_count" {
  default     = 1
  description = "Number of nodes in the Harvester cluster"
  
}

variable "metro" {
  default     = "FR"
  description = "Metro to deploy the Harvester cluster"
  
}