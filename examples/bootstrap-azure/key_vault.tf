resource "azurerm_key_vault" "new" {
  name                            = "${local.prefix}"
  resource_group_name             = "${azurerm_resource_group.new.name}"
  location                        = "${var.location}"
  sku_name                        = "standard"
  tenant_id                       = "${var.key_vault_tenant_id}"
  tags                            = "${local.tags}"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
}


resource "azurerm_key_vault_access_policy" "new-user" {
  key_vault_id = "${azurerm_key_vault.new.id}"
  tenant_id = "${var.key_vault_tenant_id}"
  object_id = "${var.key_vault_object_id}"
  key_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
  ]
  secret_permissions = [
    "get",
    "list",
    "set",
    "delete",
  ]
  certificate_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
  ]
}

resource "azurerm_key_vault_access_policy" "new-app" {
  key_vault_id = "${azurerm_key_vault.new.id}"
  tenant_id = "${var.key_vault_tenant_id}"
  object_id = "${var.key_vault_object_id}"
  application_id = "${var.application_id}"
  key_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
  ]
  secret_permissions = [
    "get",
    "list",
    "set",
    "delete",
  ]
  certificate_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
  ]
}