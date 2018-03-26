@App.controller 'HomeController', (moment, MnoeUsers, MnoeOrganizations, MnoeInvoices, MnoeAdminConfig, MnoeCurrentUser) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}

  # If finance is activated display the number of org with cc
  if MnoeAdminConfig.isPaymentEnabled()
    vm.organisationKpiLocale = 'mnoe_admin_panel.dashboard.home.kpi.organizations.finance_text'
  else
    vm.organisationKpiLocale = 'mnoe_admin_panel.dashboard.home.kpi.organizations.link_text'

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

  vm.orgTableCustomizations = {
    getOrganizations: (limit, offset, sort = 'created_at') ->
      MnoeCurrentUser.getUser().then( ->
        params = {}

        if MnoeAdminConfig.isAccountManagerEnabled()
          params['sub_tenant_id'] = MnoeCurrentUser.user.mnoe_sub_tenant_id
          params['account_manager_id'] = MnoeCurrentUser.user.id

        MnoeOrganizations.list(limit, offset, sort, params)
      )
    }

  return
