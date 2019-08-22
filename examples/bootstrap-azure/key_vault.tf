resource "azurerm_key_vault" "new" {
  name                            = "${local.prefix}"
  resource_group_name             = "${azurerm_resource_group.new.name}"
  location                        = "${var.location}"
  sku_name                        = "standard"
  tenant_id                       = "${var.key_vault_tenant_id}"
  tags                            = "${local.tags}"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  access_policy {
    tenant_id = "${var.key_vault_tenant_id}"
    object_id = "${var.key_vault_object_id}"

    certificate_permissions = [
      "get",
      "list",
      "create",
      "delete",
    ]

    key_permissions = [
      "get",
      "list",
      "create",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
    ]
  }
}
