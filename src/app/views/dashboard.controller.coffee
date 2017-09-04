@App.controller 'DashboardController', ($scope, $cookies, $sce, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, MnoeAdminConfig, STAFF_PAGE_AUTH) ->
  'ngInject'
  main = this

  main.errorHandler = MnoErrorsHandler
  main.staffPageAuthorized = STAFF_PAGE_AUTH
  main.isReviewingEnabled = MnoeAdminConfig.isReviewingEnabled()
  main.areQuestionsEnabled = MnoeAdminConfig.areQuestionsEnabled()
  main.isFinanceEnabled = MnoeAdminConfig.isFinanceEnabled()
  main.adminConfig = MnoeAdminConfig
  main.isProductEnabled = MnoeAdminConfig.isProductsEnabled()

  main.trustSrc = (src) ->
    $sce.trustAsResourceUrl(src)

  # Preload data to be reused in the app
  # Marketplace is cached
  # MnoeMarketplace.getApps()

  MnoeCurrentUser.getUser().then(
    # Display the layout
    main.user = MnoeCurrentUser.user
  )

  main.exit = ->
    MnoeCurrentUser.logout()

  return
