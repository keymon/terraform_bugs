Values being drop when passing maps between modules, templates and resources

### Note

This a quite weird and complex scenario, which can checked here:

https://github.com/keymon/terraform_bugs/tree/master/modules_templates_and_maps

You can clone it by running
```
git clone https://github.com/keymon/terraform_bugs
cd terraform_bugs/modules_templates_and_maps
terraform apply -var-file <(./vars.json.sh)
```

### Terraform Version

0.9.5 and 0.9.4.

Each work differently. I couldn't determine the commit that changed the behaviour.


### Terraform Configuration Files

Code here: https://github.com/keymon/terraform_bugs/tree/master/modules_templates_and_maps

But also:

#### `some_module/template.tf`

```hcl
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
  template = "Computed Value: $${some_var}"

  vars {
    some_var = "${
      join (", ",  null_resource.some_resource_consuming_the_map.*.triggers.entries)
    }"
  }

  depends_on = [ "null_resource.some_resource_consuming_the_map"]
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


```

#### `main.tf`

```hcl
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
  value="${join(", ", values(var.hash_map_vars))}"
}

output "module_hash_map" {
  value="${join(", ", values(module.some_module.hash_map))}"
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

```

#### `vars.json.sh`

```bash
#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
	"hash_map_vars": {
		"AAAA": "${v}",
		"BBBB": "fixed_value"
	}
}
EOF

```

To run: `terraform apply -var-file <(./vars.json.sh)`

### Expected Behavior

I would expect all the values to be the same, regardless the value of `depends_on`

```
hash_map_vars = 1495551829, fixed_value
module_hash_map = 1495551829, fixed_value, 1
some_resource_consuming_the_map = 1495551829, fixed_value, 1
some_resource_consuming_the_resource = 1495551829, fixed_value, 1
some_resource_consuming_the_template = Computed Value: 1495551829, fixed_value, 1
template_rendered = Computed Value: 1495551829, fixed_value, 1

```

### Actual Behavior


#### On 0.9.5

If you **KEEP** the `depends_on = [ "null_resource.some_resource_consuming_the_map"]` in the template, works OK:

```
hash_map_vars = 1495552206, fixed_value
module_hash_map = 1495552206, fixed_value, 1
some_resource_consuming_the_map = 1495552206, fixed_value, 1
some_resource_consuming_the_resource = 1495552206, fixed_value, 1
some_resource_consuming_the_template = Computed Value: 1495552206, fixed_value, 1
template_rendered = Computed Value: 1495552206, fixed_value, 1
```

If you **REMOVE** the `depends_on = [ "null_resource.some_resource_consuming_the_map"]` in the template,  the values of the second map are dropped from the resulting template. But the values are still available for other resources in the module.

```
hash_map_vars = 1495552096, fixed_value
module_hash_map = 1495552096, fixed_value, 1
some_resource_consuming_the_map = 1495552096, fixed_value, 1
some_resource_consuming_the_resource = 1495552096, fixed_value, 1
some_resource_consuming_the_template = Computed Value: 1495551829
template_rendered = Computed Value: 1495551829
```

And if **REMOVE** the `depends_on = [ "null_resource.some_resource_consuming_the_map"]` in the template but it is the **first run** (ie. remove `terraform.tfstate`) it works OK the first run.


#### On 0.9.4

(I include 0.9.4 for documentation and to provide additional info, might be relevant).

If you **KEEP** the `depends_on = [ "null_resource.some_resource_consuming_the_map"]` in the template, it renders everything, but alternatively:
 * uses the previous run
 * or **drops the new value** that changed

```
hash_map_vars = 1495552752, fixed_value
module_hash_map = 1495552752, fixed_value, 1
some_resource_consuming_the_map = fixed_value, 1
some_resource_consuming_the_resource = 1495552663, fixed_value, 1
some_resource_consuming_the_template = Computed Value: fixed_value, 1
template_rendered = Computed Value: fixed_value, 1
```

or

```
hash_map_vars = 1495552827, fixed_value
module_hash_map = 1495552827, fixed_value, 1
some_resource_consuming_the_map = fixed_value, 1
some_resource_consuming_the_resource = 1495552783, fixed_value, 1
some_resource_consuming_the_template = Computed Value: fixed_value, 1
template_rendered = Computed Value: fixed_value, 1
```

If you **REMOVE** the `depends_on = [ "null_resource.some_resource_consuming_the_map"]` in the template, the values of the second map are dropped from the resulting template. But the values are still available for other resources in the module. It uses the values of the old run, not the new values

```
hash_map_vars = 1495552672, fixed_value
module_hash_map = 1495552672, fixed_value, 1
some_resource_consuming_the_map = 1495552663, fixed_value, 1
some_resource_consuming_the_resource = 1495552663, fixed_value, 1
some_resource_consuming_the_template = Computed Value: 1495552663
template_rendered = Computed Value: 1495552663
```

### Important Factoids

 * **IMPORTANT** This only happens if the **FIRST** value in alphabetic order of the keys (`AAAA`) changes. If the value is constant, or if there is any other value that is constant, it won't happen.

  You can try with this alternative input:

```bash
#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
	"hash_map_vars": {
		"AAAA": "constant",
		"CCCC": "${v}",
		"BBBB": "fixed_value"
	}
}
EOF


```

 * If you add additional functions in the middle, more fun stuff can happen. I left that as an exercise for the person working on the bug. Examples, add a `upper()` function to the null resource:


### Workaround

Use latest version and `depends_on` everywhere.

### Related

I think these tickets can be related

https://github.com/hashicorp/terraform/issues/14521
https://github.com/hashicorp/terraform/issues/9080
https://github.com/hashicorp/terraform/issues/13440
