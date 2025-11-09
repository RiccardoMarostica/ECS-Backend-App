# Cognito Module

This Terraform module creates an AWS Cognito User Pool with a client application and custom domain for user authentication and authorization in your applications.

## Features

- Cognito User Pool with email-based authentication
- Configurable password policy
- User Pool Client with OAuth 2.0 support
- Custom domain for hosted UI
- Support for authorization code flow
- Configurable token validity periods
- Auto-verification of email addresses
- Deletion protection for production environments

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Resources Created

This module creates the following AWS resources:

- `aws_cognito_user_pool` - User Pool for managing users
- `aws_cognito_user_pool_client` - Client application configuration
- `aws_cognito_user_pool_domain` - Custom domain for hosted UI

## Usage

### Basic Example

```hcl
module "cognito" {
  source = "./modules/cognito"

  user_pool_name        = "myapp-users"
  user_pool_client_name = "myapp-client"
  user_pool_domain_name = "myapp-dev"
}
```

### Production Example with Custom Settings

```hcl
module "cognito" {
  source = "./modules/cognito"

  # User Pool Configuration
  user_pool_name               = "myapp-prod-users"
  user_pool_tier               = "ESSENTIAL"
  deletion_protection          = true
  auto_verified_attributes     = ["email"]
  user_pool_username_attributes = ["email"]

  # Password Policy
  password_policy_min_length        = 12
  password_policy_require_lowercase = true
  password_policy_require_uppercase = true
  password_policy_require_numbers   = true
  password_policy_require_symbols   = true

  # User Pool Client
  user_pool_client_name                  = "myapp-prod-client"
  user_pool_client_generate_scret        = true
  user_pool_client_access_token_validity = 1
  user_pool_client_id_token_validity     = 1
  user_pool_client_refresh_token_validity = 30

  # OAuth Configuration
  user_pool_client_allow_oauth_flows     = true
  user_pool_client_allowed_oauth_flows   = ["code"]
  user_pool_client_allowed_oauth_scopes  = ["openid", "email", "profile"]
  user_pool_client_callback_urls         = ["https://app.example.com/callback"]
  user_pool_client_logout_urls           = ["https://app.example.com/logout"]

  # Domain
  user_pool_domain_name = "myapp-prod"
}
```

### Integration with API Gateway

```hcl
module "cognito" {
  source = "./modules/cognito"

  user_pool_name        = "myapp-users"
  user_pool_client_name = "myapp-client"
  user_pool_domain_name = "myapp-dev"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  rest_api_name                         = "myapp-api"
  rest_api_stage_name                   = "dev"
  rest_api_authorizer_name              = "cognito-authorizer"
  rest_api_authorizer_cognito_provider  = [module.cognito.cognito_user_pool_arn]
  alb_vpc_link_id                       = module.alb.alb_vpc_link_id
  alb_listener_arn                      = module.alb.listener_arn
}
```

### Custom Domain with ACM Certificate

```hcl
# Create ACM certificate first
resource "aws_acm_certificate" "cognito" {
  domain_name       = "auth.example.com"
  validation_method = "DNS"
}

module "cognito" {
  source = "./modules/cognito"

  user_pool_name                   = "myapp-users"
  user_pool_client_name            = "myapp-client"
  user_pool_domain_name            = "auth.example.com"
  user_pool_domain_certificate_arn = aws_acm_certificate.cognito.arn
}
```

### Minimal Configuration for Development

```hcl
module "cognito" {
  source = "./modules/cognito"

  user_pool_name        = "dev-users"
  user_pool_client_name = "dev-client"
  user_pool_domain_name = "myapp-dev-12345"  # Must be globally unique
  
  # Relaxed password policy for development
  password_policy_min_length        = 8
  password_policy_require_symbols   = false
  
  # Include Postman callback for API testing
  user_pool_client_callback_urls = [
    "https://localhost/callback",
    "https://oauth.pstmn.io/v1/callback"
  ]
}
```

## Variables

### User Pool Variables

#### Required Variables

| Name | Description | Type |
|------|-------------|------|
| user_pool_name | The name of the user pool | `string` |
| user_pool_client_name | The name of the user pool client | `string` |
| user_pool_domain_name | The domain name | `string` |

#### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| password_policy_min_length | The minimum length of the password policy | `number` | `8` |
| password_policy_require_lowercase | Whether the password policy requires lowercase characters | `bool` | `true` |
| password_policy_require_numbers | Whether the password policy requires numbers | `bool` | `true` |
| password_policy_require_symbols | Whether the password policy requires symbols | `bool` | `true` |
| password_policy_require_uppercase | Whether the password policy requires uppercase characters | `bool` | `true` |
| auto_verified_attributes | The attributes to be auto-verified | `list(string)` | `["email"]` |
| user_pool_username_attributes | The attributes to be set as username | `list(string)` | `["email"]` |
| deletion_protection | Whether to enable deletion protection | `bool` | `false` |
| user_pool_tier | The user pool feature plan, or tier | `string` | `"LITE"` |

### User Pool Client Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| user_pool_client_access_token_validity | The validity of the access token (hours) | `number` | `24` |
| user_pool_client_id_token_validity | The validity of the id token (hours) | `number` | `24` |
| user_pool_client_refresh_token_validity | The validity of the refresh token (days) | `number` | `30` |
| user_pool_client_generate_scret | Whether to generate a client secret | `bool` | `true` |
| user_pool_client_explicit_auth_flows | The explicit authentication flows | `list(string)` | `["ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]` |
| user_pool_client_allow_oauth_flows | Whether to allow OAuth flows | `bool` | `true` |
| user_pool_client_allowed_oauth_flows | The allowed OAuth flows | `list(string)` | `["code"]` |
| user_pool_client_allowed_oauth_scopes | The allowed OAuth scopes | `list(string)` | `["openid", "email", "profile", "aws.cognito.signin.user.admin"]` |
| user_pool_client_callback_urls | The callback URLs | `list(string)` | `["https://localhost/callback", "https://oauth.pstmn.io/v1/callback"]` |
| user_pool_client_logout_urls | The logout URLs | `list(string)` | `["https://localhost/logout"]` |

### User Pool Domain Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| user_pool_domain_certificate_arn | The ARN of the ACM Certificate issued by AWS | `string` | `""` |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| cognito_user_pool_id | The ID of the Cognito User Pool | No |
| cognito_user_pool_arn | The ARN of the Cognito User Pool | No |
| cognito_user_pool_client_id | The ID of the Cognito User Pool Client | No |
| cognito_user_pool_client_secret | The client secret of the Cognito User Pool Client | Yes |
| cognito_user_pool_domain | The domain of the Cognito User Pool | No |

## User Pool Tiers

AWS Cognito offers three pricing tiers:

| Tier | Monthly Active Users | Features |
|------|---------------------|----------|
| LITE | Up to 50,000 | Basic authentication |
| ESSENTIAL | Unlimited | + Advanced security features |
| PRO | Unlimited | + All features including risk-based authentication |

## Authentication Flows

The module enables three authentication flows by default:

1. **USER_PASSWORD_AUTH**: Direct username/password authentication
2. **USER_SRP_AUTH**: Secure Remote Password protocol
3. **REFRESH_TOKEN_AUTH**: Token refresh capability

## OAuth 2.0 Configuration

The module supports OAuth 2.0 authorization code flow:

- **Flow**: Authorization Code Grant
- **Scopes**: openid, email, profile, aws.cognito.signin.user.admin
- **Callback URLs**: Configurable (defaults include localhost and Postman)
- **Logout URLs**: Configurable

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Application                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Authentication Request
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Cognito User Pool Domain                        │
│              (Hosted UI)                                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Login Page                                           │  │
│  │  - Email/Password                                     │  │
│  │  - Password Policy Enforcement                        │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Validate Credentials
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Cognito User Pool                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  User Directory                                       │  │
│  │  - Email (username)                                   │  │
│  │  - Password (hashed)                                  │  │
│  │  - User Attributes                                    │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Token Generation                                     │  │
│  │  - ID Token (user identity)                           │  │
│  │  - Access Token (API access)                          │  │
│  │  - Refresh Token (token renewal)                      │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Return Tokens
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              User Pool Client                                │
│              (Application Configuration)                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Tokens
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Client Application                              │
│              (Uses tokens for API calls)                     │
└─────────────────────────────────────────────────────────────┘
```

## Usage Examples

### Creating a User

```bash
aws cognito-idp sign-up \
  --client-id <client-id> \
  --username user@example.com \
  --password 'MyPassword123!' \
  --user-attributes Name=email,Value=user@example.com
```

### Confirming a User (Admin)

```bash
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id <user-pool-id> \
  --username user@example.com
```

### Authenticating a User

```bash
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client-id> \
  --auth-parameters USERNAME=user@example.com,PASSWORD='MyPassword123!'
```

### Using the Hosted UI

```
https://<domain>.auth.<region>.amazoncognito.com/login?
  client_id=<client-id>&
  response_type=code&
  scope=openid+email+profile&
  redirect_uri=<callback-url>
```

## Troubleshooting

### Common Issues

#### 1. Domain Name Already Exists

**Error:**
```
Error: error creating Cognito User Pool Domain: InvalidParameterException: Domain already exists
```

**Solution:**

Cognito domain names must be globally unique. Try a different name:

```hcl
user_pool_domain_name = "myapp-dev-${random_id.suffix.hex}"
```

Or use a custom domain with ACM certificate.

#### 2. Invalid Password

**Error:**
```
InvalidPasswordException: Password did not conform with policy
```

**Solution:**

Ensure passwords meet the configured policy:

```
- Minimum length: 8 characters (configurable)
- Requires: lowercase, uppercase, numbers, symbols (configurable)
```

Example valid password: `MyPass123!`

#### 3. User Not Confirmed

**Error:**
```
UserNotConfirmedException: User is not confirmed
```

**Solution:**

Users must verify their email before signing in:

```bash
# Admin confirm (for testing)
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id <pool-id> \
  --username user@example.com

# Or user confirms via email link
```

#### 4. Client Secret Required

**Error:**
```
NotAuthorizedException: Unable to verify secret hash for client
```

**Solution:**

If `user_pool_client_generate_scret = true`, you must include the secret hash in authentication requests. For simpler testing:

```hcl
user_pool_client_generate_scret = false
```

#### 5. Invalid Redirect URI

**Error:**
```
InvalidParameterException: Invalid redirect_uri
```

**Solution:**

Ensure the redirect URI is in the callback URLs list:

```hcl
user_pool_client_callback_urls = [
  "https://app.example.com/callback",
  "https://localhost:3000/callback"  # Add all valid URIs
]
```

#### 6. Cannot Delete User Pool

**Error:**
```
Error: error deleting Cognito User Pool: InvalidParameterException: User pool cannot be deleted
```

**Solution:**

If deletion protection is enabled:

```hcl
deletion_protection = false  # Set to false first
```

Then run `terraform apply` before destroying.

#### 7. Token Expired

**Error:**
```
NotAuthorizedException: Access Token has expired
```

**Solution:**

Use the refresh token to get new tokens:

```bash
aws cognito-idp initiate-auth \
  --auth-flow REFRESH_TOKEN_AUTH \
  --client-id <client-id> \
  --auth-parameters REFRESH_TOKEN=<refresh-token>
```

#### 8. Custom Domain Certificate Issues

**Error:**
```
InvalidParameterException: The certificate must be in us-east-1
```

**Solution:**

ACM certificates for Cognito custom domains must be in us-east-1:

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cognito" {
  provider    = aws.us_east_1
  domain_name = "auth.example.com"
  # ...
}
```

## Limitations

1. **Email Only**: Only supports email as username (no phone number)
2. **Single Schema Attribute**: Only email attribute is configured
3. **No MFA**: Multi-factor authentication not configured
4. **No Lambda Triggers**: Pre/post authentication triggers not supported
5. **No Advanced Security**: Advanced security features not enabled
6. **No User Groups**: User groups not configured
7. **No Identity Providers**: Social/SAML identity providers not configured
8. **Typo in Variable**: `user_pool_client_generate_scret` should be "secret"

## Best Practices

1. **Enable Deletion Protection**: Always enable in production
```hcl
deletion_protection = true
```

2. **Use Strong Password Policies**: Enforce strong passwords
```hcl
password_policy_min_length = 12
```

3. **Short Token Validity**: Use shorter token validity for better security
```hcl
user_pool_client_access_token_validity = 1  # 1 hour
user_pool_client_id_token_validity     = 1  # 1 hour
```

4. **Use Custom Domains**: Use custom domains for better branding
```hcl
user_pool_domain_name            = "auth.example.com"
user_pool_domain_certificate_arn = aws_acm_certificate.cognito.arn
```

5. **Limit OAuth Scopes**: Only grant necessary scopes
```hcl
user_pool_client_allowed_oauth_scopes = ["openid", "email"]
```

6. **Use ESSENTIAL or PRO Tier**: For production workloads
```hcl
user_pool_tier = "ESSENTIAL"
```

## Security Considerations

- Passwords are hashed and never stored in plaintext
- Email verification required by default
- Tokens have configurable expiration times
- Client secrets are marked as sensitive in Terraform
- OAuth 2.0 authorization code flow is secure for web apps
- Consider enabling MFA for production
- Consider enabling advanced security features (requires ESSENTIAL or PRO tier)

## Cost Considerations

Cognito pricing by tier:

**LITE Tier (Default):**
- First 50,000 MAUs: Free
- Additional MAUs: Not available (must upgrade)

**ESSENTIAL Tier:**
- $0.0055 per MAU (Monthly Active User)
- Minimum: ~$0 (pay per use)

**PRO Tier:**
- $0.0150 per MAU
- Includes advanced security features

Estimated monthly cost:
- Development (< 50K MAUs): $0 (LITE tier)
- Production (10K MAUs): $55/month (ESSENTIAL) or $150/month (PRO)

## Future Enhancements

- Add MFA support (SMS, TOTP)
- Add Lambda triggers for custom authentication flows
- Add user groups and role-based access control
- Add social identity providers (Google, Facebook, etc.)
- Add SAML identity provider support
- Add advanced security features configuration
- Add custom email/SMS templates
- Add user migration support
- Fix typo in variable name (generate_scret -> generate_secret)
- Add support for phone number as username
- Add custom attributes configuration

## Notes

- **Typo in Variable**: `user_pool_client_generate_scret` has a typo (should be "secret"). This is maintained for backward compatibility.
- **Domain Uniqueness**: Cognito domain names must be globally unique across all AWS accounts
- **Email Verification**: Users must verify their email before they can sign in
- **Token Validity Units**: Access and ID tokens use hours, refresh tokens use days
- **Locals File**: The module uses locals.tf for conditional logic based on OAuth settings

## License

See the LICENSE file in the root of the repository.
