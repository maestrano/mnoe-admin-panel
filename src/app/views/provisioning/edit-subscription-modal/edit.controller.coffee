@App.controller 'EditSubscriptionController', ($filter, $stateParams, $log, $state, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, MnoeAdminConfig, MnoeProvisioning, subscription) ->
  'ngInject'

  vm = this
  vm.subscription = subscription

  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.changePlan = (editAction) ->
    # Reset subscription, so that the correct subscription is fetched.
    MnoeProvisioning.setSubscription({})
    vm.closeModal()
    params = {id: vm.subscription.id, orgId: vm.subscription.organization_id, editAction: editAction}
    switch editAction
      when 'CHANGE'
        $state.go('dashboard.provisioning.order', params)
      else
        $state.go('dashboard.provisioning.additional_details', params)

  vm.editActionAvailable = (editAction) ->
    if vm.subscription.available_edit_actions
      editAction in vm.subscription.available_edit_actions
    else
      false

  return
