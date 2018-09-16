@App.controller 'HomeController', ($cookies, moment, MnoeUsers, MnoeOrganizations, MnoeCurrentUser, MnoeInvoices, MnoeAdminConfig, UserRoles) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}
  # User is a support manager, and thus have limited roles unless proven otherwise below.
  vm.isSupportAgent = true

  MnoeCurrentUser.getUser().then(
    (user) ->
      vm.user = user
      vm.isSupportAgent = UserRoles.isSupportAgent(user)
      # Upon initial load of the home page, before the resolve redirects, we may hit this function.
      vm.findMetrics() unless vm.isSupportAgent
      vm.isLoading = false
  )

  # If finance is activated display the number of org with cc
  if MnoeAdminConfig.isPaymentEnabled()
    vm.organisationKpiLocale = 'mnoe_admin_panel.dashboard.home.kpi.organizations.finance_text'
  else
    vm.organisationKpiLocale = 'mnoe_admin_panel.dashboard.home.kpi.organizations.link_text'

  vm.findMetrics = () ->
    # API calls
    MnoeUsers.metrics().then(
      (response) ->
        vm.users.metrics = response.data.metrics
    )

    MnoeOrganizations.count().then(
      (response) ->
        vm.organizations.kpi = response.data
    )

    MnoeInvoices.lastInvoicingAmount().then(
      (response) ->
        vm.invoices.lastInvoicingAmount = response.data
    ) if MnoeAdminConfig.isFinanceEnabled()

    MnoeInvoices.outstandingAmount().then(
      (response) ->
        vm.invoices.outstandingAmount = response.data
    ) if MnoeAdminConfig.isFinanceEnabled()

  return
