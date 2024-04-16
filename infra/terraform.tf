# tfstate is stored on Terraform Cloud
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "a-mt"

    workspaces {
      name = "test-django-dev"
    }
  }
}
