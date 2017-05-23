# container definition template mapping
data "template_file" "example_template" {
  template = "${file("${path.module}/template.tmpl")}"

  vars {
    container_env = "${
      join (",",  null_resource._jsonencode_container_env.*.triggers.entries)
    }"
  }

  depends_on = [ "null_resource._jsonencode_container_env"]
}

resource "null_resource" "_jsonencode_container_env" {
  triggers {
    entries = "${element(values(var.container_env), count.index)}"
  }
  count = "${length(var.container_env)}"
}
variable "container_env" {
  description = "Environment parameters passed to the container"
  type        = "map"
  default     = {}
}


output "rendered" {
  value="${data.template_file.example_template.rendered}"
}

