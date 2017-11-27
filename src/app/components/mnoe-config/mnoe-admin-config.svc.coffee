# This service is a wrapper around the config we fetch from the backend
@App.factory 'MnoeAdminConfig', ($log, ADMIN_ROLES, ADMIN_PANEL_CONFIG, DASHBOARD_CONFIG) ->
  _self = @

  # Only expose subtenant_admin when subtenants are enabled
  @adminRoles = () ->
    if _self.isSubTenantEnabled()
      ADMIN_ROLES
    else
      _.reject(ADMIN_ROLES, (role) -> role.value == 'sub_tenant_admin')

  @isAppManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.apps_management?.enabled?
      ADMIN_PANEL_CONFIG.apps_management.enabled
    else
      true

  @isAuditLogEnabled = () ->
    if ADMIN_PANEL_CONFIG.audit_log?.enabled?
      ADMIN_PANEL_CONFIG.audit_log.enabled
    else
      true

  @isDashboardTemplatesEnabled = ->
    if ADMIN_PANEL_CONFIG.dashboard_templates?.enabled?
      ADMIN_PANEL_CONFIG.dashboard_templates.enabled
    else
      false

  @isFinanceEnabled = () ->
    if ADMIN_PANEL_CONFIG.finance?.enabled?
      ADMIN_PANEL_CONFIG.finance.enabled
    else
      true

  @isImpersonationEnabled = () ->
    if ADMIN_PANEL_CONFIG.impersonation?.enabled?
      ADMIN_PANEL_CONFIG.impersonation.enabled
    else
      true

  @isImpersonationConsentRequired = () ->
    if ADMIN_PANEL_CONFIG.impersonation?.consent_required?
      ADMIN_PANEL_CONFIG.impersonation.consent_required
    else
      false

  @isOrganizationManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management?.organization?.enabled?
      ADMIN_PANEL_CONFIG.customer_management.organization.enabled

  @areLocalProductsEnabled = () ->
    if DASHBOARD_CONFIG.marketplace?.local_products?
      DASHBOARD_CONFIG.marketplace.local_products
    else
      $log.debug("DASHBOARD_CONFIG.marketplace.local_products")
      false

  @isProductMarkupEnabled = () ->
    if DASHBOARD_CONFIG.marketplace?.product_markup?
      DASHBOARD_CONFIG.marketplace.product_markup
    else
      $log.debug("DASHBOARD_CONFIG.marketplace.provisioning")
      true

  @isProvisioningEnabled = () ->
    if DASHBOARD_CONFIG.marketplace?.provisioning?
      DASHBOARD_CONFIG.marketplace.provisioning
    else
      $log.debug("DASHBOARD_CONFIG.marketplace.provisioning")
      false

  # Do not display CC info if Billing or Payment is disabled in the frontend
  @isPaymentEnabled = () ->
    payment_disabled = (DASHBOARD_CONFIG.payment? && not DASHBOARD_CONFIG.payment.enabled)
    billing_disabled = (DASHBOARD_CONFIG.organization_management?.billing? && not DASHBOARD_CONFIG.organization_management.billing.enabled)

    not (payment_disabled || billing_disabled)

  @areQuestionsEnabled  = () ->
    if DASHBOARD_CONFIG.marketplace?.questions?.enabled?
      DASHBOARD_CONFIG.marketplace.questions.enabled
    else
      false

  @isRegistrationEnabled = () ->
    if DASHBOARD_CONFIG.registration?.enabled?
      DASHBOARD_CONFIG.registration.enabled
    else
      true

  @isReviewingEnabled = () ->
    if DASHBOARD_CONFIG.marketplace?.reviews?.enabled?
      DASHBOARD_CONFIG.marketplace.reviews.enabled
    else
      false

  @isStaffEnabled = () ->
    if ADMIN_PANEL_CONFIG.staff?.enabled?
      ADMIN_PANEL_CONFIG.staff.enabled
    else
      true

  @areSettingsEnabled = () ->
    if ADMIN_PANEL_CONFIG.settings?.enabled?
      ADMIN_PANEL_CONFIG.settings.enabled
    else
      true

  @isSubTenantEnabled = () ->
    if ADMIN_PANEL_CONFIG.sub_tenant?.enabled?
      ADMIN_PANEL_CONFIG.sub_tenant.enabled
    else
      false

  @isUserManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management?.user?.enabled?
      ADMIN_PANEL_CONFIG.customer_management.user.enabled
    else
      true

  @marketplaceCurrency = () ->
    if DASHBOARD_CONFIG.marketplace?.pricing?.currency?
      DASHBOARD_CONFIG.marketplace.pricing.currency
    else
      $log.debug("DASHBOARD_CONFIG.marketplace.pricing.currency missing")
      'AUD'

  @availableBillingCurrencies = () ->
    if ADMIN_PANEL_CONFIG.available_billing_currencies?
      ADMIN_PANEL_CONFIG.available_billing_currencies
    else
      $log.debug("ADMIN_PANEL_CONFIG.billing_currencies missing")
      ['AED', 'AUD', 'CAD', 'EUR', 'GBP', 'HKD', 'JPY', 'NZD', 'SGD', 'USD']

  @isCustomerBatchImportEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_batch_import?.enabled?
      ADMIN_PANEL_CONFIG.customer_batch_import.enabled
    else
      false

  return @
