variable "region" {
    type = string
    description = "Region de AWS"
    default = "us-east-1"
}

variable "project_name" {
    type = string
    description = "Nombre del proyecto"
    default = "aws-lambda-integration"
}

variable "environment" {
    type = string
    description = "Ambientes del proyecto (DEV, QA y PROD)"
}

variable "suffix" {
    type = string
    description = "Suffix para el bucket"
    default = "iaclabafc276733"
}
