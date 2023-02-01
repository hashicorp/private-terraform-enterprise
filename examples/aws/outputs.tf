# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "replicated console password" {
  value = "${random_pet.replicated-pwd.id}"
}
