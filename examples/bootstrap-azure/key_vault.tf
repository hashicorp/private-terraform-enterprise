# read in current AzureRM client config so we can give it some permissions wrt the Keyvault.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "new" {
  name                            = "${local.prefix}"
  resource_group_name             = "${azurerm_resource_group.new.name}"
  location                        = "${var.location}"
  sku_name                        = "standard"
  tenant_id                       = "${var.key_vault_tenant_id}" # The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.
  tags                            = "${local.tags}"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
}

# access policy for the ecurrent signed in user building the vault.
resource "azurerm_key_vault_access_policy" "tf-user" {
  key_vault_id = "${azurerm_key_vault.new.id}"
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.service_principal_object_id}"
  key_permissions = [
    "backup",
    "create",
    "decrypt",
    "delete",
    "encrypt",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "sign",
    "unwrapKey",
    "update",
    "verify",
    "wrapKey",
  ]

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set",
  ]
    certificate_permissions = [
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "setissuers",
    "update",
  ]
}

# access policy for the required/created/dedicated/selected keyvault SP user
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

# access policy for the required/created/dedicated/selected keyvault SP user
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

