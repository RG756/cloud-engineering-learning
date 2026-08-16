# -------------------------------------------
# Entra ID SAML Identity Provider
# -------------------------------------------
resource "aws_cognito_identity_provider" "entra_id" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "EntraID"
  provider_type = "SAML"

  provider_details = {
    MetadataFile = file("${path.module}/entra-metadata.xml")
    IDPSignout   = "false"
  }

  attribute_mapping = {
    email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    # name → objectidentifier に変更（OIDはスペースなし・永続的・一意）
    username = "http://schemas.microsoft.com/identity/claims/objectidentifier"
    name     = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  }
}