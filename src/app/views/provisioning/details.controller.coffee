@App.controller('ProvisioningDetailsCtrl', ($state, MnoeProvisioning) ->
  vm = this

  vm.form = [ "*" ]

  vm.subscription = MnoeProvisioning.getSubscription()
  vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

  # The schema is contained in field vm.product.custom_schema
  MnoeProvisioning.findProduct(id: vm.subscription.product.id).then(
    (response) ->
      vm.schema = JSON.parse(response.custom_schema)
  )

  vm.submit = (form) ->
    return if form.$invalid
    MnoeProvisioning.setSubscription(vm.subscription)
    $state.go('dashboard.provisioning.confirm')

  return
)
