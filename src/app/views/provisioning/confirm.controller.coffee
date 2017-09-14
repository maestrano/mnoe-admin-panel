@App.controller('ProvisioningConfirmCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig) ->
  vm = this

  vm.isLoading = true
  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getSubscription()

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  ).finally(-> vm.isLoading = false)

  vm.validate = () ->
    vm.isLoading = true
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      ->
        $state.go('dashboard.provisioning.order_summary', {orgId: $stateParams.orgId})
    ).finally(-> vm.isLoading = false)

  return
)
