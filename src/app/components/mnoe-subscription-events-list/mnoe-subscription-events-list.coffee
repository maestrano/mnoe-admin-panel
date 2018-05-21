#
# Mnoe organizations List
#
@App.component('mnoeSubscriptionEventsList', {
  templateUrl: 'app/components/mnoe-subscription-events-list/mnoe-subscription-events-list.html',
  bindings: {
    all: '<'
    filters: '<'
  }
  controller: ($uibModal, $stateParams, toastr, MnoeCurrentUser, MnoConfirm, MnoeProvisioning, UserRoles) ->
    ctrl = this
    ctrl.organizationId = $stateParams.orgId

    MnoeCurrentUser.getUser().then(
      (response) ->
        ctrl.isAccountManager = UserRoles.isAccountManager(response)
      )

    ctrl.subscriptionEvents =
      list: []
      sort: "created_at.desc"
      nbItems: 10
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.subscriptionEvents.nbItems = nbItems
        ctrl.subscriptionEvents.page = page
        ctrl.subscriptionEvents.offset = (page  - 1) * nbItems
        fetchSubscriptionEvents(nbItems, ctrl.subscriptionEvents.offset)

      approve: (subscriptionEvent) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.close'
          actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.cancel'
          headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.proceed'
          bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.perform'
          bodyTextExtraData: {subscription_name: subscriptionEvent.subscription.product_name}
          actionCb: ->
            MnoeProvisioning.approveSubscriptionEvent({id: subscriptionEvent.id}).then(() ->
              fetchSubscriptionEvents(ctrl.subscriptionEvents.nbItems, ctrl.subscriptionEvents.offset)
              ).then(() ->
                toastr.success('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_success', {extraData: {subscription_name: subscriptionEvent.subscription.product_name}})
              ).catch(() ->
                toastr.error('mnoe_admin_panel.dashboard.subscriptions.modal.approve_subscriptions.toastr_error', {extraData: {subscription_name: subscriptionEvent.subscription.product_name}})
              )
        MnoConfirm.showModal(modalOptions)

      reject: (subscriptionEvent) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.close'
          actionButtonText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.cancel'
          headerText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.proceed'
          bodyText: 'mnoe_admin_panel.dashboard.subscriptions.modal.cancel_subscriptions.perform'
          bodyTextExtraData: {subscription_name: subscriptionEvent.subscription.product_name}
          type: 'danger'
          actionCb: ->
            MnoeProvisioning.rejectSubscriptionEvent({id: subscriptionEvent.id}).then(() ->
              fetchSubscriptionEvents(ctrl.subscriptionEvents.nbItems, ctrl.subscriptionEvents.offset)
              ).then(() ->
                toastr.success('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_success', {extraData: {subscription_name: subscriptionEvent.subscription.product_name}})
              ).catch(() ->
                toastr.error('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_error', {extraData: {subscription_name: subscriptionEvent.subscription.product_name}})
              )

        MnoConfirm.showModal(modalOptions)

    fetchSubscriptionEvents = (limit, offset, sort = ctrl.subscriptionEvents.sort) ->
      ctrl.subscriptionEvents.loading = true

      # Add extra filtering
      extra_params = ctrl.filters || {}
      # Either get all the subscription events of a tenant, or just the subscription events of an organization.
      if ctrl.organizationId
        return MnoeProvisioning.getOrganizationsSubscriptionEvents(limit, offset, sort, ctrl.organizationId, extra_params).then(
          (response) ->
            ctrl.subscriptionEvents.totalItems = response.headers('x-total-count')
            ctrl.subscriptionEvents.list = response.data
            ctrl.subscriptionEvents.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
        ).finally(->
          ctrl.subscriptionEvents.loading = false
          )
      else
        return MnoeProvisioning.getAllSubscriptionEvents(limit, offset, sort, extra_params).then(
          (response) ->
            ctrl.subscriptionEvents.totalItems = response.headers('x-total-count')
            ctrl.subscriptionEvents.list = response.data
            ctrl.subscriptionEvents.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
        ).finally(-> ctrl.subscriptionEvents.loading = false)

    ctrl.$onInit = ->
      ctrl.titleText = "mnoe_admin_panel.dashboard.subscriptions.widget.list.#{ctrl.titleKey || 'title'}"

    # Manage sorting and server call
    ctrl.callServer = (tableState) ->
      # Update the sort parameter
      sort = updateSort(tableState.sort)
      # Call the server
      fetchSubscriptionEvents(ctrl.subscriptionEvents.nbItems, ctrl.subscriptionEvents.offset, sort)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      # Default sort
      sort = "created_at.desc"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update subscriptions sort
      ctrl.subscriptionEvents.sort = sort
      return sort

    ctrl.displayInfoTooltip = (subscriptionEvent) ->
      subscriptionEvent.status == 'error'

    ctrl.editToolTip = (editAction) ->
      'mnoe_admin_panel.dashboard.subscriptions.widget.list.table.' + editAction.toLowerCase() + '_tooltip'

    ctrl.displayStatusInfo = ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/orders/order-status-info-modal/order-status-info.html'
        controller: 'OrderInfoController'
        controllerAs: 'vm'
      )

    ctrl.showEditAction = (subscription, editAction) ->
      editAction in subscription.available_actions

    return
})
