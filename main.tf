module "some_module" {
    source = "./some_module"
    container_env = "${
        merge(
            var.container_env,
            map(
                "CONSUMED_VALUE", null_resource.some_resource.triggers.foo,
            )
        )
    }"

}

resource "null_resource" "some_resource" {
  triggers {
   foo = "1"
  }
}

variable "container_env" {
  type        = "map"

}

output "rendered" {
  value="${module.some_module.rendered}"
}


