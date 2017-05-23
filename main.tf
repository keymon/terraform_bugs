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

output "hash_map_vars" {
  value="${var.hash_map_vars}"
}

output "module_hash_map" {
  value="${module.some_module.hash_map}"
}

output "some_resource_consuming_the_map" {
  value="${module.some_module.some_resource_consuming_the_map}"
}

output "template_rendered" {
  value="${module.some_module.template_rendered}"
}

output "some_resource_consuming_the_template" {
  value="${module.some_module.some_resource_consuming_the_template}"
}

output "some_resource_consuming_the_resource" {
  value="${module.some_module.some_resource_consuming_the_resource}"
}



