variable "a_hash_map" {
  type        = "map"
  default     = {}
}

output "hash_map" {
  value="${var.a_hash_map}"
}

resource "null_resource" "some_resource_consuming_the_map" {
  triggers {
    entries = "${element(values(var.a_hash_map), count.index)}"
  }
  count = "${length(var.a_hash_map)}"
}

output "some_resource_consuming_the_map" {
  value="${join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)}"
}

data "template_file" "example_template" {
  template = "${file("${path.module}/template.tmpl")}"

  vars {
    some_var = "${
      join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)
    }"
  }

  #depends_on = [ "null_resource.some_resource_consuming_the_map"]
}

output "template_rendered" {
  value="${data.template_file.example_template.rendered}"
}

resource "null_resource" "some_resource_consuming_the_template" {
  triggers {
    entries = "${data.template_file.example_template.rendered}"
  }
}

output "some_resource_consuming_the_template" {
  value="${null_resource.some_resource_consuming_the_template.triggers.entries}"
}

resource "null_resource" "some_resource_consuming_the_resource" {
  triggers {
    entries = "${join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)}"
  }
}

output "some_resource_consuming_the_resource" {
  value="${null_resource.some_resource_consuming_the_resource.triggers.entries}"
}

