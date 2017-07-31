@App.controller 'DashboardController',
  ($scope, $cookies, $sce, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, MnoeAdminConfig,
    STAFF_PAGE_AUTH, REVIEWS_CONFIG, QUESTIONS_CONFIG, SUB_TENANT_CONFIG) ->
    'ngInject'
    main = this

    main.errorHandler = MnoErrorsHandler
    main.staffPageAuthorized = STAFF_PAGE_AUTH
    main.isReviewingEnabled = REVIEWS_CONFIG && REVIEWS_CONFIG.enabled
    main.areQuestionsEnabled = QUESTIONS_CONFIG && QUESTIONS_CONFIG.enabled
    main.isFinanceEnabled = MnoeAdminConfig.isFinanceEnabled()
    main.isSubTenantEnabled = SUB_TENANT_CONFIG && SUB_TENANT_CONFIG.enabled
    main.adminConfig = MnoeAdminConfig

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
