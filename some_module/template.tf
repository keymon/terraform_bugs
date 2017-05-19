# container definition template mapping
data "template_file" "example_template" {
  template = "${file("${path.module}/template.tmpl")}"

  vars {
    container_env = "${
      join (
        format(",\n      "),
        concat(
          null_resource._jsonencode_container_env.*.triggers.entries
        )
      )
    }${
      (
        length(null_resource._jsonencode_container_env.*.triggers.entries)
      ) != 0 ? "," : ""
    }"
  }

  depends_on = [ "null_resource._jsonencode_container_env"]
}

# Create a json snippet with the list of variables
#
# It will use a null_resource to generate a list of json encoded
# name-value maps like {"name": "...", "value": "..."}, and then
# we join them in a data template file.
#
resource "null_resource" "_jsonencode_container_env" {
  triggers {
    entries = "${
      jsonencode(
        map(
          "name", element(keys(var.container_env), count.index),
          "value", element(values(var.container_env), count.index),
          )
      )
    }"
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

