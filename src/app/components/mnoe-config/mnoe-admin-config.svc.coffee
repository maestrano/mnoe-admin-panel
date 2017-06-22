# This service is a wrapper around the config we fetch from the backend
@App.factory 'MnoeAdminConfig', ($log, ADMIN_PANEL_CONFIG, DASHBOARD_CONFIG) ->
  _self = @

  @isAuditLogEnabled = () ->
    if ADMIN_PANEL_CONFIG.audit_log?
      ADMIN_PANEL_CONFIG.audit_log.enabled
    else
      true

  @isImpersonationEnabled = () ->
    if ADMIN_PANEL_CONFIG.impersonation?
      ADMIN_PANEL_CONFIG.impersonation.enabled
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
    if ADMIN_PANEL_CONFIG.customer_management?.organization?
      ADMIN_PANEL_CONFIG.customer_management.organization.enabled
    else
      true

  @isUserManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management?.customer_management.user?
      ADMIN_PANEL_CONFIG.customer_management.user.enabled
    else
      true

  # Do not display CC info if Billing or Payment is disabled in the frontend
  @isPaymentEnabled = () ->

    payment_disabled = (DASHBOARD_CONFIG.payment? && not DASHBOARD_CONFIG.payment.enabled)
    billing_disabled = (DASHBOARD_CONFIG.organization_management?.billing? && not DASHBOARD_CONFIG.organization_management.billing.enabled)

    not (payment_disabled || billing_disabled)

  @isReviewingEnabled = () ->
    DASHBOARD_CONFIG.reviews?.enabled

  return @
