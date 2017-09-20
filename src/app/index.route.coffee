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

  if adminConfig.isDashboardTemplatesEnabled()
    $stateProvider
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
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdmin()

  if adminConfig.isFinanceEnabled()
    $stateProvider
      .state 'dashboard.finance',
        data:
          pageTitle:'Finance'
        url: '/finance'
        templateUrl: 'app/views/finance/finance.html'
        controller: 'FinanceController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.finance.title'

      .state 'dashboard.invoices',
        data:
          pageTitle:'Invoices'
        url: '/invoices'
        templateUrl: 'app/views/invoices/invoices.html'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.invoices.title'
      .state 'dashboard.invoice',
        data:
          pageTitle:'Invoice'
        url: '^/invoice/:invoiceId'
        templateUrl: 'app/views/invoices/invoice.html'
        controller: 'InvoiceController'
        controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.invoice.title'

  if adminConfig.isStaffEnabled()
    $stateProvider.state 'dashboard.staffs',
      data:
        pageTitle:'Staffs'
      url: '/staffs'
      templateUrl: 'app/views/staffs/staffs.html'
      controller: 'StaffsController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.staffs.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdminRole(['admin', 'sub_tenant_admin'])
    .state 'dashboard.staff',
      data:
        pageTitle:'Division'
      url: '^/staff/:staffId'
      views: '@dashboard':
        templateUrl: 'app/views/staff/staff.html'
        controller: 'StaffController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.staffs.title'
      resolve:
        skip: (MnoeCurrentUser) -> MnoeCurrentUser.skipIfNotAdminRole(['admin', 'sub_tenant_admin'])
    .state 'dashboard.sub-tenants',
      data:
        pageTitle:'Divisions'
      url: '/sub-tenants'
      templateUrl: 'app/views/sub-tenants/sub-tenants.html'
      controller: 'SubTenantsController'
      controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.sub_tenants.title'
      resolve:
        skip: (MnoeCurrentUser, MnoeAdminConfig) -> MnoeCurrentUser.skipIfNotAdminRole(['admin']) || !MnoeAdminConfig.isSubTenantEnabled()
    .state 'dashboard.sub-tenant',
      data:
        pageTitle:'Division'
      url: '^/sub-tenant/:subTenantId'
      views: '@dashboard':
        templateUrl: 'app/views/sub-tenant/sub-tenant.html'
        controller: 'SubTenantController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.sub_tenant.title'

  if adminConfig.isOrganizationManagementEnabled()
    $stateProvider.state 'dashboard.customers.create-step-1',
      url: '^/customers/create-customer'
      views: '@dashboard':
        templateUrl: 'app/views/customers/create-step-1/create-step-1.html'
        controller: 'CreateStep1Controller'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.customers.create_customer.title'

  if adminConfig.isOrganizationManagementEnabled() && adminConfig.isCustomerBatchImportEnabled()
    $stateProvider.state 'dashboard.customers.batch-upload',
      url: '^/customers/batch-upload'
      views: '@dashboard':
        templateUrl: 'app/views/customers/batch-upload/batch-upload.html'
        controller: 'BatchUploadController'
        controllerAs: 'vm'
      ncyBreadcrumb:
        label: 'mnoe_admin_panel.dashboard.customers.batch_upload.title'

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
        url: '/details/?orgId'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/details.html'
          controller: 'ProvisioningDetailsCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.additional_details'
      .state 'dashboard.provisioning.confirm',
        data:
          pageTitle:'Purchase - Confirm'
        url: '/confirm/?orgId'
        views: '@dashboard.provisioning':
          templateUrl: 'app/views/provisioning/confirm.html'
          controller: 'ProvisioningConfirmCtrl'
          controllerAs: 'vm'
        ncyBreadcrumb:
          label: 'mnoe_admin_panel.dashboard.provisioning.breadcrumb.confirm'
      .state 'dashboard.provisioning.order_summary',
        data:
          pageTitle:'Purchase - Order summary'
        url: '/summary/?orgId'
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
        url: '^/orders/?:orderId&:orgId'
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
