variable "rancher_api_url" {
  default     = ""
  description = "Rancher API endpoint to manager your Harvester cluster"
  type        = string
}

variable "rancher_access_key" {
  default     = ""
  description = "Rancher access key"
  type        = string
}

variable "rancher_secret_key" {
  default     = ""
  description = "Rancher secret key"
  type        = string
}

variable "rancher_insecure" {
  default     = false
  description = "Allow insecure connections to the Rancher API"
  type        = bool
}

variable "ssh_key" {
  default     = ""
  description = "SSH key to use for the Harvester cluster"
  type        = string
}

variable "project_name" {
  default     = "test"
  description = "Name of the project to create the Harvester cluster"
  type        = string
}

variable "node_count" {
  default     = 1
  description = "Number of nodes in the Harvester cluster"
  type        = number
}

variable "metro" {
  default     = "FR"
  description = "Metro to deploy the Harvester cluster"
  type        = string
}

variable "auth_token" {
  default     = ""
  description = "Equinix API authentication token"
  type        = string
}

variable "ssh_private_key_file" {
  default     = ""
  description = "Path to private key file for Harvester Host"
  type        = string
}

variable "cluster_count" {
  default     = 1
  description = "Amount of cluster to provision"
  type        = number
}

variable "hostname_prefix" {
  default     = "harvester-cl"
  description = "hostname prefix"
  type        = string
}

variable "bootstrap_password" {
  default     = "admin"
  description = "Bootstrap password for admin"
  type        = string
}

variable "harvester_password" {
  description = "Password for harvester admin user"
  type        = string
}

variable "rancher_bootstrap_password" {
  default     = "Rancher1234-"
  description = "Rancher Bootstrap Password"
  type        = string
}

variable "rancher_password" {
  type        = string
  description = "Rancher Password for Admin User"
}