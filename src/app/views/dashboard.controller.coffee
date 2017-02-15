@App.controller 'DashboardController', ($scope, $cookies, $sce, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, STAFF_PAGE_AUTH, REVIEWS_CONFIG) ->
  'ngInject'
  main = this

  main.errorHandler = MnoErrorsHandler
  main.staffPageAuthorized = STAFF_PAGE_AUTH

  main.isReviewingEnabled = REVIEWS_CONFIG && REVIEWS_CONFIG.enabled

  main.trustSrc = (src) ->
    $sce.trustAsResourceUrl(src)

  # Preload data to be reused in the app
  # Marketplace is cached
  # MnoeMarketplace.getApps()

  MnoeCurrentUser.getUser().then(
    # Display the layout
    main.user = MnoeCurrentUser.user
  )

  return
