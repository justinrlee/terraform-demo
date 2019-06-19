
variable "ecs_cluster_name" {
  default = "armory-ecs"
  type    = "string"
}

variable "ecs_asg_name" {
  default = "armory-ecs"
  type    = "string"
}

variable "ami" {
    default = "ami-02507631a9f7bc956"
}

variable "ecsInstanceRole" {
    default = "ecsInstanceRole"
}

variable "instance_count" {
    default = null
}

variable "ssh_key_name" {
    default = null
}

variable "instance_type_1" {
    default = "large"
}

variable "instance_type_2" {
    default = "xlarge"
}

variable "instance_family_1" {
    default = "m5"
}

variable "instance_family_2" {
    default = "m4"
}