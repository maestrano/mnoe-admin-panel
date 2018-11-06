#
# Mnoe Subscriptions List
#
@App.component('mnoeSubscriptionsList', {
  templateUrl: 'app/components/mnoe-subscriptions-list/mnoe-subscriptions-list.html',
  bindings: {
    all: '<'
    organization: '<',
    companyCart: '<',
    filters: '<'
    titleKey: '@'
  }
  controller: ($state, $uibModal, $stateParams, MnoeAdminConfig, MnoeCurrentUser, MnoeProvisioning, UserRoles, MnoeObservables, ProvisioningHelper, OBS_KEYS) ->
    ctrl = this
    ctrl.organizationId = $stateParams.orgId
    ctrl.skipPriceSelection = ProvisioningHelper.skipPriceSelection

    MnoeCurrentUser.getUser().then(
      (response) ->
        ctrl.isAccountManager = UserRoles.isAccountManager(response)
        ctrl.isSupportAgent = UserRoles.isSupportAgent(response)
        ctrl.supportDisabledClass = UserRoles.supportDisabledClass(response)
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

    # Manage sorting and server call
    ctrl.callServer = (tableState) ->
      # Update the sort parameter
      sort = updateSort(tableState.sort)
      # Call the server
      fetchSubscriptions(ctrl.subscriptions.nbItems, ctrl.subscriptions.offset, sort)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "created_at.desc"
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

      return MnoeProvisioning.getSubscriptions(limit, offset, sort, ctrl.organizationId, extra_params).then(
        (response) ->
          ctrl.subscriptions.totalItems = response.headers('x-total-count')
          ctrl.subscriptions.list = response.data
          ctrl.subscriptions.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
      ).finally(-> ctrl.subscriptions.loading = false)

    ctrl.editToolTip = (editAction) ->
      cartText = if ctrl.companyCart && editAction == 'cancel' then 'cart.' else ''

      'mnoe_admin_panel.dashboard.subscriptions.widget.list.table.' + cartText + editAction.toLowerCase() + '_tooltip'

    ctrl.showEditAction = (subscription, editAction) ->
      return false if MnoeAdminConfig.isCurrentAccountRequired() && subscription.organization.in_arrears
      editAction in subscription.available_actions

    ctrl.pendingSubscription = (subscription) ->
      subscription.status in ['pending', 'provisioning']

    ctrl.editSubscription = (subscription, editAction) ->
      return if ctrl.isSupportAgent
      MnoeProvisioning.setSubscription({})

      params = {subscriptionId: subscription.id, orgId: subscription.organization_id, editAction: editAction, cart: ctrl.companyCart}
      switch editAction
        when 'change'
          $state.go('dashboard.provisioning.order', params)
        else
          $state.go('dashboard.provisioning.additional_details', params)

    onSubscriptionEventUpdate = () ->
      fetchSubscriptions(ctrl.subscriptions.nbItems, ctrl.subscriptions.offset)

    MnoeObservables.registerCb(OBS_KEYS.subscriptionEventChanged, onSubscriptionEventUpdate)

    return
})
