variable "a_hash_map" {
  type        = "map"
  default     = {}
}

resource "null_resource" "some_resource_consuming_the_map" {
  triggers {
    entries = "${element(values(var.a_hash_map), count.index)}"
  }
  count = "${length(var.a_hash_map)}"
}

data "template_file" "example_template" {
  template = "${file("${path.module}/template.tmpl")}"

  vars {
    some_var = "${
      join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)
    }"
  }

  depends_on = [ "null_resource.some_resource_consuming_the_map"]
}

output "null_resource_values" {
  value="${join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)}"
}

output "template_rendered" {
  value="${data.template_file.example_template.rendered}"
}

