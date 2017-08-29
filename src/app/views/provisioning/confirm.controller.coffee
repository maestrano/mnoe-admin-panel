@App.controller('ProvisioningConfirmCtrl', ($state, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig) ->
  vm = this

  vm.isLoading = false
  vm.subscription = MnoeProvisioning.getSubscription()
  vm.orgCurrency = MnoeAdminConfig.marketplaceCurrency()

  vm.validate = () ->
    vm.isLoading = true
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      ->
        $state.go('dashboard.provisioning.order_summary')
    ).finally(-> vm.isLoading = false)

  return
)
