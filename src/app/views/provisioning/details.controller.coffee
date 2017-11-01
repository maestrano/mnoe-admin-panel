@App.controller('ProvisioningDetailsCtrl', ($state, $stateParams, MnoeProvisioning, schemaForm) ->
  vm = this

  vm.form = [ "*" ]

  vm.subscription = MnoeProvisioning.getSubscription()

  # Happen when the user reload the browser during the provisioning
  if _.isEmpty(vm.subscription)
    # Redirect the user to the first provisioning screen
    $state.go('dashboard.provisioning.order', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid}, {reload: true})

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
    $state.go('dashboard.provisioning.confirm', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid})

  return
)
