#
# Mnoe organizations List
#
@App.component('mnoeSubscriptionsList', {
  templateUrl: 'app/components/mnoe-subscriptions-list/mnoe-subscriptions-list.html',
  bindings: {
    all: '<'
    organization: '<',
    filters: '<'
    titleKey: '@'
  }
  controller: ($state, $filter, $log, $uibModal, toastr, MnoeUsers, MnoeCurrentUser, MnoConfirm, MnoeProvisioning) ->
    ctrl = this

    ctrl.subscriptions =
      list: []
      sort: "created_at.desc"
      nbItems: 10
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.subscriptions.nbItems = nbItems
        ctrl.subscriptions.page = page
        ctrl.subscriptions.offset = (page  - 1) * nbItems
        fetchSubscriptions(nbItems, ctrl.subscriptions.offset)

      approve: (subscription) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.close'
          actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.cancel'
          headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.proceed'
          bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.perform'
          bodyTextExtraData: {subscription_name: subscription.product.name}
          type: 'danger'
          actionCb: ->
            MnoeProvisioning.approveSubscription({organization_id: subscription.organization.id, id: subscription.id }).then(
              (response) ->
                angular.copy(response.data.subscription, subscription)
                toastr.success('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_success', {extraData: {subscription_name: subscription.product.name}})
              ->
                toastr.error('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_error', {extraData: {subscription_name: subscription.product.name}})
            )

        MnoConfirm.showModal(modalOptions)

      cancel: (subscription) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.close'
          actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.cancel'
          headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.proceed'
          bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.perform'
          bodyTextExtraData: {subscription_name: subscription.product.name}
          type: 'danger'
          actionCb: ->
            MnoeProvisioning.cancelSubscription(subscription).then(
              (response) ->
                angular.copy(response.data.subscription, subscription)
                toastr.success('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_success', {extraData: {subscription_name: subscription.product.name}})
              ->
                toastr.error('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_error', {extraData: {subscription_name: subscription.product.name}})
            )

        MnoConfirm.showModal(modalOptions)

    ctrl.$onInit = ->
      ctrl.titleText = "mnoe_admin_panel.dashboard.subscriptions.widget.list.#{ctrl.titleKey || 'title'}"

    ctrl.$onChanges = () ->
      # Call the server when ready
      return unless (ctrl.all || angular.isDefined(ctrl.organization))
      fetchSubscriptions(ctrl.subscriptions.nbItems, ctrl.subscriptions.offset)

    # Manage sorting and server call
    ctrl.callServer = (tableState) ->
      # Do not call if not ready
      return unless (ctrl.all || angular.isDefined(ctrl.organization))
      # Update the sort parameter
      sort = updateSort(tableState.sort)
      # Call the server
      fetchSubscriptions(ctrl.subscriptions.nbItems, ctrl.subscriptions.offset, sort)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "created_at"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update subscriptions sort
      ctrl.subscriptions.sort = sort
      return sort

    # Fetch subscriptions
    fetchSubscriptions = (limit, offset, sort = ctrl.subscriptions.sort) ->
      ctrl.subscriptions.loading = true

      # Add extra filtering
      extra_params = ctrl.filters || {}

      return MnoeProvisioning.getSubscriptions(limit, offset, sort, ctrl.organization?.id, extra_params).then(
        (response) ->
          ctrl.subscriptions.totalItems = response.headers('x-total-count')
          ctrl.subscriptions.list = response.data
          ctrl.subscriptions.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
      ).finally(-> ctrl.subscriptions.loading = false)

    ctrl.displayInfoTooltip = (subscription) ->
      subscription.status == 'aborted'

    ctrl.displayStatusInfo = ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/orders/order-status-info-modal/order-status-info.html'
        controller: 'OrderInfoController'
        controllerAs: 'vm'
      )

    ctrl.showEditAction = (subscription, editAction) ->
      editAction in subscription.available_edit_actions

    ctrl.editSubscription = (subscription, editAction) ->
      MnoeProvisioning.setSubscription({})

      params = {subscriptionId: subscription.id, orgId: subscription.organization_id, editAction: editAction}
      switch editAction
        when 'CHANGE'
          $state.go('dashboard.provisioning.order', params)
        else
          $state.go('dashboard.provisioning.additional_details', params)

    return
})
