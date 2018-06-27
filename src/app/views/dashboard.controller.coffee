@App.controller 'DashboardController', ($scope, $cookies, $sce, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, MnoeAdminConfig, UserRoles, STAFF_PAGE_AUTH) ->
  'ngInject'
  main = this

  main.errorHandler = MnoErrorsHandler
  main.staffPageAuthorized = STAFF_PAGE_AUTH
  main.adminConfig = MnoeAdminConfig
  main.showProductManagement =
    MnoeAdminConfig.areLocalProductsEnabled() ||
    MnoeAdminConfig.isProductMarkupEnabled() ||
    MnoeAdminConfig.areSettingsEnabled()
  main.showWebstore =
    MnoeAdminConfig.isStaffEnabled() ||
    MnoeAdminConfig.isSubTenantEnabled() ||
    MnoeAdminConfig.isFinanceEnabled() ||
    MnoeAdminConfig.isReviewingEnabled() ||
    MnoeAdminConfig.areQuestionsEnabled() ||
    MnoeAdminConfig.isDashboardTemplatesEnabled() ||
    MnoeAdminConfig.isAuditLogEnabled()

  main.trustSrc = (src) ->
    $sce.trustAsResourceUrl(src)

  # Preload data to be reused in the app
  # Marketplace is cached
  # MnoeMarketplace.getApps()

  main.isLoading = true
  MnoeCurrentUser.getUser().then(
    # Display the layout
    (user) ->
      main.user = user
      main.organizationAvailable = user.organizations? && user.organizations.length > 0
      main.showSupportScreen = UserRoles.supportRoleForUser(user)
      main.isLoading = false
  )

  main.exit = ->
    MnoeCurrentUser.logout()

  return
