@App.controller('ProvisioningDetailsCtrl', ($state, $stateParams, MnoeProvisioning, schemaForm, EDIT_ACTIONS) ->
  vm = this

  vm.form = [ "*" ]

  vm.subscription = MnoeProvisioning.getSubscription()
  vm.availableEditActions = vm.subscription.available_edit_actions
  # Set default edit action
  vm.activeTab = vm.availableEditActions[0]

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
  vm.getSubscription = () ->
    vm.isLoading = true
    MnoeProvisioning.getProduct(vm.subscription.product.id, { editAction: vm.activeTab })
      .then((product) -> JSON.parse(product.custom_schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) ->
        vm.schema = schema
        vm.isLoading = false
        )

  vm.submit = (form) ->
    return if form.$invalid
    vm.subscription.editAction = vm.activeTab
    MnoeProvisioning.setSubscription(vm.subscription)
    $state.go('dashboard.provisioning.confirm', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid})

  vm.editButtonText = (editAction) ->
    if editAction == 'SUSPEND' && vm.subscription.status == 'suspended'
      EDIT_ACTIONS['REACTIVATE']
    else
      EDIT_ACTIONS[editAction]

  vm.getSubscription()

  return
)
