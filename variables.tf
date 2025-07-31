
variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "us-west-2"
}

variable "server_port" {
  description = "The port on which the server will run"
  type        = number
  default     = 8000
}