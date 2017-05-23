resource "null_resource" "some_resource" {
  triggers {
    foo = "1"
  }
}

output "an_ouput" {
  value = "1"
}

output "invalid_interpolation" {
  value = "${upper(map())}"
}

output "invalid attribute_in_resource" {
  value = "${null_resource.some_resource.non_existent}"
}

