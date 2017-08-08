# This service is a wrapper around the config we fetch from the backend
@App.factory 'MnoeAdminConfig', ($log, ADMIN_PANEL_CONFIG, DASHBOARD_CONFIG) ->
  _self = @

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
    else
      true

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

  @isUserManagementEnabled = () ->
    if ADMIN_PANEL_CONFIG.customer_management?.user?.enabled?
      ADMIN_PANEL_CONFIG.customer_management.user.enabled
    else
      true

  return @
