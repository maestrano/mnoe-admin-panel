@App.config ($stateProvider, $urlRouterProvider, MnoeAdminConfigProvider) ->
  'ngInject'
  $stateProvider
    .state 'dashboard',
      abstract: true,
      templateUrl: 'app/views/dashboard.layout.html'
      controller: 'DashboardController'
      controllerAs: 'main'
    .state 'dashboard.home',
      data:
        pageTitle:'Home'
      url: '/home'
      templateUrl: 'app/views/home/home.html'
      controller: 'HomeController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.home.title'
    .state 'dashboard.reviews',
      data:
        pageTitle:'Reviews'
      url: '/reviews'
      templateUrl: 'app/views/reviews/reviews.html'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.reviews.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
        skipCondition: (RoutingHelper, MnoeAdminConfig) -> RoutingHelper.skipUnlessCondition(MnoeAdminConfig.isReviewingEnabled())
    .state 'dashboard.questions',
      data:
        pageTitle:'Questions'
      url: '/questions'
      templateUrl: 'app/views/questions/questions.html'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.questions.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
        skipCondition: (RoutingHelper, MnoeAdminConfig) -> RoutingHelper.skipUnlessCondition(MnoeAdminConfig.areQuestionsEnabled())
    .state 'dashboard.customers',
      data:
        pageTitle:'Customers'
      url: '/customers'
      templateUrl: 'app/views/customers/customers.html'
      controller: 'CustomersController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.customers.title'
    .state 'dashboard.customers.user',
      data:
        pageTitle:'User'
      url: '^/user/:userId'
      views: '@dashboard':
        templateUrl: 'app/views/user/user.html'
        controller: 'UserController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.user.title'
    .state 'dashboard.customers.organization',
      data:
        pageTitle:'Organization'
      url: '^/organization/:orgId'
      views: '@dashboard':
        templateUrl: 'app/views/organization/organization.html'
        controller: 'OrganizationController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.organization.title'
    .state 'dashboard.customers.connect-app',
      url: '^/customers/:orgId/connect-apps'
      views: '@dashboard':
        templateUrl: 'app/views/customers/connect-app/connect-app.html'
        controller: 'ConnectAppController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.customers.connect_app.title'
    .state 'dashboard.product-markups',
      data:
        pageTitle: 'Price List'
      url: '/product-markups'
      templateUrl: 'app/views/product-markups/product-markups.html'
      controller: 'ProductMarkupsController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.product_markups.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()

  # Routes depending on Feature Flags
  adminConfig = MnoeAdminConfigProvider.$get()

  if adminConfig.areSettingsEnabled()
    $stateProvider
      .state 'dashboard.settings-general',
        data:
          pageTitle: 'Frontend Settings'
        url: '/settings/general'
        templateUrl: 'app/views/settings/general/general.html'
        controller: 'SettingsGeneralController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.settings.title'
        resolve:
          skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
      .state 'dashboard.settings-apps',
        data:
          pageTitle: 'Apps Selection'
        url: '/settings/apps'
        templateUrl: 'app/views/settings/apps/apps.html'
        controller: 'SettingsAppsController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.settings.apps.title'
        resolve:
          skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
      .state 'dashboard.settings-plugins',
        data:
          pageTitle: 'Plugins Settings'
        url: '/settings/plugins'
        templateUrl: 'app/views/settings/plugins/plugins.html'
        controller: 'SettingsPluginsController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.settings.plugins.title'
        resolve:
          skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
      .state 'dashboard.settings-domain',
        data:
          pageTitle: 'Domain & SSL'
        url: '/settings/domain'
        templateUrl: 'app/views/settings/domain/domain.html'
        controller: 'SettingsDomainController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.settings.domain.title'
        resolve:
          skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()

  if adminConfig.isAuditLogEnabled()
    $stateProvider.state 'dashboard.audit-log',
      data:
        pageTitle:'Audit Log'
      url: '/audit-log'
      templateUrl: 'app/views/audit-log/audit-log.html'
      controller: 'AuditLogController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.audit_log.title'

  if adminConfig.isFinanceEnabled()
    $stateProvider.state 'dashboard.finance',
      data:
        pageTitle:'Finance'
      url: '/finance'
      templateUrl: 'app/views/finance/finance.html'
      controller: 'FinanceController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.finance.title'

  if adminConfig.isStaffEnabled()
    $stateProvider.state 'dashboard.staff',
      data:
        pageTitle:'Staff'
      url: '/staff' #:staffId
      templateUrl: 'app/views/staff/staff.html'
      controller: 'StaffController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.staff.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()

  if adminConfig.isOrganizationManagementEnabled()
    $stateProvider.state 'dashboard.customers.create-step-1',
      url: '^/customers/create-customer'
      views: '@dashboard':
        templateUrl: 'app/views/customers/create-step-1/create-step-1.html'
        controller: 'CreateStep1Controller'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.customers.create_customer.title'

  if adminConfig.isOrganizationManagementEnabled() && adminConfig.isProvisioningEnabled()
    $stateProvider
      .state 'dashboard.provisioning',
        abstract: true
        templateUrl: 'app/views/provisioning/layout.html'
        url: '/provisioning'
      .state 'dashboard.provisioning.order',
        data:
          pageTitle:'Purchase - Order'
        url: '/order/?nid&id&orgId'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/order.html'
          controller: 'ProvisioningOrderCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.order'
      .state 'dashboard.provisioning.additional_details',
        data:
          pageTitle:'Purchase - Additional details'
        url: '/details/'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/details.html'
          controller: 'ProvisioningDetailsCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.additional_details'
      .state 'dashboard.provisioning.confirm',
        data:
          pageTitle:'Purchase - Confirm'
        url: '/confirm/'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/confirm.html'
          controller: 'ProvisioningConfirmCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.confirm'
      .state 'dashboard.provisioning.order_summary',
        data:
          pageTitle:'Purchase - Order summary'
        url: '/summary/'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/summary.html'
          controller: 'ProvisioningSummaryCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.order_summary'

  if adminConfig.isProvisioningEnabled()
    $stateProvider
      .state 'dashboard.orders',
        data:
          pageTitle:'Orders'
        url: '/orders'
        templateUrl: 'app/views/orders/orders.html'
        controller: 'OrdersController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.orders.title'
      .state 'dashboard.order',
        data:
          pageTitle:'Order'
        url: '^/orders/:ordId'
        views: '@dashboard':
          templateUrl: 'app/views/orders/order.html'
          controller: 'OrderController'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.order.title'

  if adminConfig.areLocalProductsEnabled()
    $stateProvider
      .state 'dashboard.products',
        data:
          pageTitle:'Products'
        url: '/products'
        views: '@dashboard':
          templateUrl: 'app/views/products/products.html'
          controller: 'ProductsController'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.products.title'
      .state 'dashboard.product',
        data:
          pageTitle:'Product'
        url: '^/product/:productId'
        views: '@dashboard':
          templateUrl: 'app/views/products/product.html'
          controller: 'ProductController'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.product.title'

  $urlRouterProvider.otherwise '/home'
