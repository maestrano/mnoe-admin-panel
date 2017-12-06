# This service is a wrapper around the config we fetch from the backend
# MnoeAdminConfig.financeEnabled?
@App.factory 'MnoeAdminConfig', ($log, ADMIN_PANEL_CONFIG, INTERCOM_ID, PAYMENT_CONFIG, ORGANIZATION_MANAGEMENT, DEVISE_CONFIG) ->
  _self = @

  @isAuditLogEnabled = () ->
    if ADMIN_PANEL_CONFIG.audit_log
      ADMIN_PANEL_CONFIG.audit_log.enabled
    else
      true

  @isIntercomEnabled = () ->
    if ADMIN_PANEL_CONFIG.intercom?
      ADMIN_PANEL_CONFIG.intercom.enabled && INTERCOM_ID?
    else
      false

  @isImpersonationEnabled = () ->
    if ADMIN_PANEL_CONFIG.impersonation
      not ADMIN_PANEL_CONFIG.impersonation.disabled
    else
      true

  @isStaffEnabled = () ->
    if ADMIN_PANEL_CONFIG.staff?
      ADMIN_PANEL_CONFIG.staff.enabled
    else
      true

  @isFinanceEnabled = () ->
    if ADMIN_PANEL_CONFIG.finance?
      ADMIN_PANEL_CONFIG.finance.enabled
    else
      true

  @isAppManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.apps_management?
      ADMIN_PANEL_CONFIG.apps_management.enabled
    else
      true

  @isOrganizationManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management? && ADMIN_PANEL_CONFIG.customer_management.organization?
      ADMIN_PANEL_CONFIG.customer_management.organization.enabled
    else
      true

  @isRegistrationEnabled = () ->
    if DEVISE_CONFIG.registration?.disabled?
      not DEVISE_CONFIG.registration.disabled
    else
      true

  @isUserManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management? && ADMIN_PANEL_CONFIG.customer_management.user?
      ADMIN_PANEL_CONFIG.customer_management.user.enabled
    else
      true

  @isSubTenantEnabled = () ->
    if ADMIN_PANEL_CONFIG.sub_tenant?
      ADMIN_PANEL_CONFIG.sub_tenant.enabled
    else
      false

  # If the feature is enabled a "staff" user can be assigned to customers and can only see those ones
  # If the feature is disabled, the screen to assign customers is not showing and a staff can see all customers (only difference with "admin" in this case is some screens are limited)
  @isAccountManagerEnabled = () ->
    if ADMIN_PANEL_CONFIG.account_manager?
      ADMIN_PANEL_CONFIG.account_manager.enabled
    else
      false

  # Do not display CC info if Billing or Payment is disabled in the frontend
  @isPaymentEnabled = () ->
    payment_disabled = (PAYMENT_CONFIG? && PAYMENT_CONFIG.disabled)
    billing_disabled = (ORGANIZATION_MANAGEMENT? && ORGANIZATION_MANAGEMENT.billing? && not ORGANIZATION_MANAGEMENT.billing.enabled)

    not (payment_disabled || billing_disabled)

  @isDashboardTemplatesEnabled = ->
    ADMIN_PANEL_CONFIG.dashboard_templates? && ADMIN_PANEL_CONFIG.dashboard_templates.enabled

  return @
