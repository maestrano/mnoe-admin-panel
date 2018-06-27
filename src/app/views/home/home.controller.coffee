@App.controller 'HomeController', ($cookies, moment, MnoeUsers, MnoeOrganizations, MnoeCurrentUser, MnoeInvoices, MnoeAdminConfig) ->
  'ngInject'
  vm = this

  MnoeCurrentUser.getUser().then(
    (user) ->
      vm.user = user
      vm.showSupportScreen = !$cookies["organization_external_id"] && user.admin_role == 'support'
      vm.findMetrics() unless vm.showSupportScreen
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
