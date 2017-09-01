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

  # Routes depending on Feature Flags
  adminConfig = MnoeAdminConfigProvider.$get()

  if adminConfig.areSettingsEnabled()
    $stateProvider
      .state 'dashboard.settings',
        data:
          pageTitle: 'Frontend Settings'
        url: '/settings'
        templateUrl: 'app/views/settings/settings.html'
        controller: 'SettingsController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.settings.title'
        resolve:
          skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()
      .state 'dashboard.domain',
        data:
          pageTitle: 'Domain & SSL'
        url: '/settings/domain'
        templateUrl: 'app/views/settings/domain.html'
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

    $stateProvider.state 'dashboard.invoices',
      data:
        pageTitle:'Invoices'
      url: '/invoices'
      templateUrl: 'app/views/invoices/invoices.html'
      controller: 'InvoicesController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.invoices.title'
    $stateProvider.state 'dashboard.invoice',
      data:
        pageTitle:'Invoice'
      url: '^/invoice/:invoiceId'
      templateUrl: 'app/views/invoices/invoice.html'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.invoice.title'

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

  $urlRouterProvider.otherwise '/home'
