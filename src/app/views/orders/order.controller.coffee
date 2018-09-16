@App.controller 'OrderController', ($filter, $state, $stateParams, $uibModal, toastr, MnoeProvisioning, MnoeOrganizations, MnoeUsers, MnoConfirm, MnoeProducts, MnoeCurrentUser, UserRoles) ->
  'ngInject'
  vm = this

  vm.subscriptionId = $stateParams.subscriptionId
  vm.orgId = $stateParams.orgId
  vm.orderId = $stateParams.orderId
  vm.order = {}
  vm.subscription = {}
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

  vm.showNoDetailsProvied = (custom_data) ->
    _.isEmpty(custom_data)

  fetchSubscriptionEvent = () ->
    return unless vm.orderId
    MnoeProvisioning.getSubscriptionEvent(vm.subscriptionId, vm.orgId, vm.orderId).then((response) ->
      vm.order = response.data.subscription_event
      )

  # If the user is viewing a specific #subscription_event(order), fetch it, otherwise show the user's non-obsolete #subscription_event
  if vm.orderId
    fetchSubscriptionEvent()

  fetchSubscription = () ->
    # Get the subscription
    MnoeProvisioning.fetchSubscription(vm.subscriptionId, vm.orgId).then(
      (response) ->
        vm.subscription = response.data.plain()
        vm.getInfo()
        if vm.subscription.externally_provisioned?
          MnoeProducts.fetchCustomSchema(vm.subscription.product.id).then((response) ->
            return unless response
            schema = JSON.parse(response)
            vm.schema = schema.json_schema || schema
            vm.form = schema.asf_options || ["*"]
        )
      ).finally(-> vm.isLoading = false)

  fetchSubscription()

  fetchSubscriptionEvents = () ->
    MnoeProvisioning.getSubscriptionEvents(vm.subscriptionId, vm.orgId, null, null, 'created_at.desc').then(
      (response) ->
        vm.subscriptionEvents = response.data.plain()

        # If the user is not viewing a specific order, show the non-obsolete subscription event.
        unless vm.orderId
          vm.order = _.find(vm.subscriptionEvents, (s) -> !s.obsolete)
    )

  fetchSubscriptionEvents()

  MnoeCurrentUser.getUser().then(
    (response) ->
      vm.isAccountManager = UserRoles.isAccountManager(response)
      vm.isSupportAgent = UserRoles.isSupportAgent(response)
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

  vm.displayInfoTooltip = ->
    vm.order.status == 'aborted' if vm.order

  # Admin can only accept/reject a #subscription_event(i.e. order) when subscription event is requested.
  vm.orderUnalterable = ->
    vm.order && (vm.order.status != 'requested')

  vm.disableApprovalWorkflow = ->
    vm.orderUnalterable() || vm.isAccountManager || vm.isSupportAgent

  vm.orderWorkflowExplanation = ->
    if vm.orderUnalterable()
      'mnoe_admin_panel.dashboard.subscriptions.modal.approve_disabled'

  vm.approveOrder = ->
    modalOptions =
      closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.close'
      actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.cancel'
      headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.perform'
      bodyTextExtraData: {subscription_name: vm.subscription.product.name}
      actionCb: ->
        MnoeProvisioning.approveSubscriptionEvent({id: vm.order.id}).then(() ->
          fetchSubscriptionEvents()
          fetchSubscriptionEvent()
          fetchSubscription()
          ).then(() ->
            toastr.success('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_success', {extraData: {subscription_name: vm.subscription.product.name}})
          ).catch(() ->
            toastr.error('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_error', {extraData: {subscription_name: vm.subscription.product.name}})
          )
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
        MnoeProvisioning.rejectSubscriptionEvent({id: vm.order.id}).then(() ->
          fetchSubscriptionEvents()
          fetchSubscriptionEvent()
          ).then(() ->
            toastr.success('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_success', {extraData: {subscription_name: vm.subscription.product.name}})
          ).catch(() ->
            toastr.error('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_error', {extraData: {subscription_name: vm.subscription.product.name}})
          )
    MnoConfirm.showModal(modalOptions)

  vm.displayStatusInfo = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/orders/order-status-info-modal/order-status-info.html'
      controller: 'OrderInfoController'
      controllerAs: 'vm'
    )

  vm.openSubscriptionEventInfoModal = (subscriptionEvent, subscription) ->
    $uibModal.open(
      templateUrl: 'app/views/orders/subscription-event-info-modal/subscription-event-info.html'
      controller: 'subscriptionEventInfoCtrl'
      controllerAs: 'vm',
      resolve:
        event: subscriptionEvent
        subscription: subscription
    )

  return vm
