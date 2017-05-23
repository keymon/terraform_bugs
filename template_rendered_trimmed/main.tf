data "template_file" "example_template" {
  template = <<EOF


This template has empty lines above and below


EOF
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
