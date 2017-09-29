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
        skipCondition: (RoutingHelper, REVIEWS_CONFIG) -> RoutingHelper.skipUnlessCondition(REVIEWS_CONFIG && REVIEWS_CONFIG.enabled)
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
        skipCondition: (RoutingHelper, QUESTIONS_CONFIG) -> RoutingHelper.skipUnlessCondition(QUESTIONS_CONFIG && QUESTIONS_CONFIG.enabled)
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
    .state 'dashboard.dashboard-templates',
      url: '/dashboard-templates'
      templateUrl: 'app/views/dashboard-templates/dashboard-templates.html'
      controller: 'DashboardTemplatesController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.dashboard_templates.title'
    .state 'dashboard.dashboard-templates-create',
      url: '/dashboard-templates/create'
      templateUrl: 'app/views/impac/impac.html'
      controller: 'ImpacController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.impac.title'
      resolve:
        action: -> { value: 'create' }
    .state 'dashboard.dashboard-templates-edit',
      url: '/dashboard-templates/:dashboardId/edit'
      templateUrl: 'app/views/impac/impac.html'
      controller: 'ImpacController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.impac.title'
      resolve:
        action: -> { value: 'edit' }

  # Routes depending on Feature Flags
  adminConfig = MnoeAdminConfigProvider.$get()

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

  if adminConfig.isTasksEnabled()
    $stateProvider.state 'dashboard.messages',
      data:
        pageTitle: 'Messages'
      url: '/messages'
      templateUrl: 'app/views/messages/messages.html'
      controller: 'MessagesController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.messages.title'

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
