@App.controller('ProvisioningDetailsCtrl', ($state, $stateParams, MnoeProvisioning, schemaForm) ->
  vm = this

  vm.form = [ "*" ]

  vm.subscription = MnoeProvisioning.getSubscription()
  vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

  # The schema is contained in field vm.product.custom_schema
  #
  # jsonref is used to resolve $ref references
  # jsonref is not cyclic at this stage hence the need to make a
  # reasonable number of passes (2 below + 1 in the sf-schema directive)
  # to resolve cyclic references
  #
  MnoeProvisioning.findProduct(id: vm.subscription.product.id)
    .then((response) -> JSON.parse(response.custom_schema))
    .then((schema) -> schemaForm.jsonref(schema))
    .then((schema) -> schemaForm.jsonref(schema))
    .then((schema) -> vm.schema = schema)

  vm.submit = (form) ->
    return if form.$invalid
    MnoeProvisioning.setSubscription(vm.subscription)
    $state.go('dashboard.provisioning.confirm', {orgId: $stateParams.orgId})

  return
)
