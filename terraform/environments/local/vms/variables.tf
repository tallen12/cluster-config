variable "connect_url" {
  description = "The url to the local connect server."
  type        = string
  sensitive = false
  default = "http://localhost:8080"
}

variable "connect_token" {
  description = "The open connect token."
  type        = string
  sensitive = true
}