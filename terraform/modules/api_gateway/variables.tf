variable "rest_api_name" {
  description = "The name of the REST API"
  type        = string
}

variable "rest_api_disable_execute_endpoint" {
  description = "Whether clients can invoke the REST API using the default execute-api endpoint"
  type        = bool
  default     = false
}

variable "rest_api_endpoint_ip_address_type" {
  description = "The IP address type that can invoke an API"
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "ipv6"], var.rest_api_endpoint_ip_address_type)
    error_message = "The IP address type must be \"ipv4\" or \"ipv6\"."
  }
}

variable "rest_api_endpoint_type" {
  description = "The type of endpoint for the REST API"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL"], var.rest_api_endpoint_type)
    error_message = "The endpoint type must be \"EDGE\", \"REGIONAL\"."
  }
}
