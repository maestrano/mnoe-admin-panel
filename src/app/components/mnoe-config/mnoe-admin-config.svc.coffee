# This service is a wrapper around the config we fetch from the backend
# TODO: service or factory?

# MnoeAdminConfig.financeEnabled?
@App.factory 'MnoeAdminConfig', ($log, ADMIN_PANEL_CONFIG) ->
  _self = @

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

  return @
