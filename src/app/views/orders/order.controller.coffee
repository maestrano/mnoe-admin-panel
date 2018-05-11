@App.controller 'OrderController', ($filter, $state, $stateParams, $uibModal, toastr, MnoeProvisioning, MnoeOrganizations, MnoeUsers, MnoConfirm, MnoeProducts, MnoeCurrentUser) ->
  'ngInject'
  vm = this

  vm.subscriptionId = $stateParams.subscriptionId
  vm.orgId = $stateParams.orgId
  vm.orderId = $stateParams.orderId
  vm.order = {}
  vm.rootName = $filter('translate')('mnoe_admin_panel.dashboard.order.root_name')
  vm.organization = {}
  vm.user = {}
  vm.isLoading = true
  vm.fulfillment_status = [
    {value: 'Y', text: 'mnoe_admin_panel.dashboard.order.fulfillment_yes'},
    {value: 'N', text: 'mnoe_admin_panel.dashboard.order.fulfillment_no'}
  ]

  # Configure user friendly json tree
  vm.jsonTreeSettings = {
    toggleBranchText: $filter('translate')('mnoe_admin_panel.dashboard.order.click_to_expand'),
    emptyValueText: $filter('translate')('mnoe_admin_panel.dashboard.order.no_data'),
    dateFormat: 'yyyy-MM-dd HH:mm:ss'
  }

  # if vm.orderId

  # Get the subscription
  MnoeProvisioning.fetchSubscription(vm.subscriptionId, vm.orgId).then(
    (response) ->
      vm.subscription = response.data.plain()
      vm.getInfo()
      if vm.subscription.custom_data?
        MnoeProducts.fetchCustomSchema(vm.subscription.product.id).then((response) ->
          schema = JSON.parse(response)
          vm.schema = if schema.json_schema then schema.json_schema else {}
          vm.form = if schema.asf_options then schema.asf_options else ["*"]
      )
    ).finally(-> vm.isLoading = false)

  fetchSubscriptionEvents = () ->
    MnoeProvisioning.getSubscriptionEvents(vm.subscriptionId, vm.orgId).then(
      (response) ->
        vm.subscriptionEvents = response.data.subscription_events
        # If the user is not viewing a specific order, show the non-obsolete subscription event.
        unless vm.orderId
          vm.order = _.find(response.data.subscription_events, (s) -> !s.obsolete)

    )

  fetchSubscriptionEvents()

  MnoeCurrentUser.getUser().then(
    (response) ->
      vm.isAccountManager = (response.admin_role == 'staff')
  )

  vm.getInfo = ->
    MnoeOrganizations.get(vm.orgId).then(
      (response) ->
        vm.organization = response.data.plain()
    )
    if vm.subscription.user_id?
      MnoeUsers.get(vm.subscription.user_id).then(
        (response) ->
          vm.user = response.data.plain()
      )

  # Display approval if status is 'requested' or if product is not externally provisioned
  vm.displayApproval = ->
    return ( vm.order.status == 'requested' || vm.order.externally_provisioned )

  # Display fulfill otherwise
  vm.displayFulfillApproval = ->
    return !vm.displayApproval()

  vm.displayInfoTooltip = ->
    return vm.order.status == 'aborted'

  # Make sure Approval is disabled for any other status than 'requested'
  vm.disableApproval = ->
    return (vm.order.status != 'requested')

  # Fulfill disabled if not shown or if shown but status is cancelled
  vm.disableFulfillApproval = ->
    return !vm.displayFulfillApproval() || (vm.order.status == 'cancelled')  || (vm.order.status == 'fulfilled')

  # Only disabled cancel if status is already cancelled
  vm.disableCancel = ->
    return (vm.order.status != 'requested')

  vm.orderWorkflowExplanation = ->
    if vm.displayFulfillApproval() && vm.disableFulfillApproval()
      return 'mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_disabled'
    if vm.displayApproval() && vm.disableApproval()
      return 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_disabled'

  vm.approveOrder = ->
    modalOptions =
      closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.close'
      actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.cancel'
      headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.perform'
      bodyTextExtraData: {subscription_name: vm.subscription.product.name}
      type: 'danger'
      actionCb: ->
        MnoeProvisioning.approveSubscription({organization_id: vm.orgId, id: vm.subscriptionId }).then(
          (response) ->
            angular.copy(response.data.subscription, vm.subscription)
            toastr.success('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_success', {extraData: {subscription_name: vm.subscription.product.name}})
          ->
            toastr.error('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_error', {extraData: {subscription_name: vm.subscription.product.name}})
        ).finally(() -> fetchSubscriptionEvents())

    MnoConfirm.showModal(modalOptions)

  vm.fulfillOrder = ->
    modalOptions =
      closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.close'
      actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.cancel'
      headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.perform'
      bodyTextExtraData: {subscription_name: vm.subscription.product.name}
      type: 'danger'
      actionCb: ->
        MnoeProvisioning.fulfillSubscription({organization_id: vm.orgId, id: vm.subscriptionId }).then(
          (response) ->
            angular.copy(response.data.subscription, vm.subscription)
            toastr.success('mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.toastr_success', {extraData: {subscription_name: vm.subscription.product.name}})
          ->
            toastr.error('mnoe_admin_panel.dashboard.subscriptions.modal.fulfill_subscriptions.toastr_error', {extraData: {subscription_name: vm.subscription.product.name}})
        ).finally(() -> fetchSubscriptionEvents())

    MnoConfirm.showModal(modalOptions)

  vm.cancelOrder = ->
    modalOptions =
      closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.close'
      actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.cancel'
      headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.perform'
      bodyTextExtraData: {subscription_name: vm.subscription.product.name}
      type: 'danger'
      actionCb: ->
        MnoeProvisioning.cancelSubscription({organization_id: vm.orgId, id: vm.subscriptionId }).then(
          (response) ->
            angular.copy(response.data.subscription, vm.subscription)
            toastr.success('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_success', {extraData: {subscription_name: vm.subscription.product.name}})
          ->
            toastr.error('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_error', {extraData: {subscription_name: vm.subscription.product.name}})
        ).finally(() -> fetchSubscriptionEvents())

    MnoConfirm.showModal(modalOptions)

  vm.displayStatusInfo = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/orders/order-status-info-modal/order-status-info.html'
      controller: 'OrderInfoController'
      controllerAs: 'vm'
    )

  return vm
