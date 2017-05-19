module "some_module" {
    source = "./some_module"
    container_env = "${
        merge(
        var.container_env,
        map(
            "DATABASE_HOSTNAME", null_resource.some_resource.triggers.foo,
            "SERVER_ID", var.secrets["SERVER_ID"],
            "LICENSE_KEY", var.secrets["LICENSE_KEY"],
            "DATABASE_PASSWORD", var.secrets["DATABASE_PASSWORD"]
        )
        )
    }"
    infra_container_env = "${var.infra_container_env}"

}

resource "null_resource" "some_resource" {
  triggers {
   foo = "1"
  }
}
variable "secrets" {
  type        = "map"

}

variable "container_env" {
  type        = "map"

}
variable "infra_container_env" {
  type        = "map"
}


output "rendered" {
  value="${module.some_module.rendered}"
}
output "rendered_in_resource" {
  value="${module.some_module.rendered}"
}


