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

    MnoeCurrentUser.getUser().then(
      (response) ->
        ctrl.isAccountManager = (response.admin_role == 'staff')
      )

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

    ctrl.editSubscription = (subscription, editAction) ->
      MnoeProvisioning.setSubscription({})

      params = {subscriptionId: subscription.id, orgId: subscription.organization_id, editAction: editAction}
      switch editAction
        when 'change'
          $state.go('dashboard.provisioning.order', params)
        else
          $state.go('dashboard.provisioning.additional_details', params)

    return
})
