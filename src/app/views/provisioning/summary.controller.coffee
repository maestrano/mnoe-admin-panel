@App.controller('ProvisioningSummaryCtrl', ($q, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig) ->
  vm = this

  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getSubscription()

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  )

  return
)
