@App.controller('ProvisioningSummaryCtrl', (MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig) ->
  vm = this

  vm.subscription = MnoeProvisioning.getSubscription()
  vm.orgCurrency = MnoeAdminConfig.marketplaceCurrency()

  return
)
