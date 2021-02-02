#------------------------------------------------------------------------------
# Variables that need to be set
#------------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to work in"
  type        = string
  default     = "ap-southeast-2"
}

variable "tf_project" {
  description = "The name of the project folder that inputs.tfvars is in"
  type        = string
}
