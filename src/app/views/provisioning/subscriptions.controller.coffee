@App.controller('ProvisioningSubscriptionsCtrl', ($stateParams, toastr, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, MnoConfirm) ->
  vm = this

  vm.isLoading = true
  vm.orgCurrency = MnoeAdminConfig.marketplaceCurrency()

  vm.cancelSubscription = (subscription, i) ->
    modalOptions =
      headerText: 'mnoe_admin_panel.dashboard.provisioning.subscriptions.cancel_modal.title'
      bodyText: 'mnoe_admin_panel.dashboard.provisioning.subscriptions.cancel_modal.body'
      closeButtonText: 'mnoe_admin_panel.dashboard.provisioning.subscriptions.cancel_modal.no'
      actionButtonText: 'mnoe_admin_panel.dashboard.provisioning.subscriptions.cancel_modal.yes'
      actionCb: -> MnoeProvisioning.cancelSubscription(subscription).then(
        (response) ->
          angular.copy(response.subscription, vm.subscriptions[i])
        ->
          toastr.error('mnoe_admin_panel.dashboard.provisioning.subscriptions.cancel_error')
      )
      type: 'danger'

    MnoConfirm.showModal(modalOptions)

  MnoeProvisioning.getSubscriptions(50).then(
    (response) ->
      console.log("### DEBUG response", response)
      vm.subscriptions = response.data
  ).finally(-> vm.isLoading = false)

  return
)
