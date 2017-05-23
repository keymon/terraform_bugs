module "some_module" {
    source = "./some_module"
    a_hash_map = "${
        merge(
            var.hash_map_vars,
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

variable "hash_map_vars" {
  type = "map"

}

output "null_resource_values" {
  value="${module.some_module.null_resource_values}"
}

output "template_rendered" {
  value="${module.some_module.template_rendered}"
}


