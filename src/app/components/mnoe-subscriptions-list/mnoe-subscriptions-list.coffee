#
# Mnoe organizations List
#
@App.component('mnoeSubscriptionsList', {
  templateUrl: 'app/components/mnoe-subscriptions-list/mnoe-subscriptions-list.html',
  bindings: {
    all: '<'
    organization: '<'
  }
  controller: ($filter, $log, toastr, MnoeUsers, MnoeCurrentUser, MnoConfirm, MnoeProvisioning) ->
    ctrl = this

    ctrl.subscriptions =
      list: []
      sort: "start_date"
      nbItems: 10
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.subscriptions.nbItems = nbItems
        ctrl.subscriptions.page = page
        ctrl.subscriptions.offset = (page  - 1) * nbItems
        fetchSubscriptions(nbItems, ctrl.subscriptions.offset)

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
                console.log("### DEBUG response.data.subscription", response.data)
                angular.copy(response.data.subscription, subscription)
                toastr.success('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_success', {extraData: {subscription_name: subscription.name}})
              ->
                toastr.error('mnoe_admin_panel.dashboard.subscriptions.widget.list.toastr_error', {extraData: {subscription_name: subscription.name}})
            )

        MnoConfirm.showModal(modalOptions)

    # Manage sorting and server call
    ctrl.callServer = (tableState) ->
      # Do not call if not ready
      return unless (ctrl.all == true || angular.isDefined(ctrl.organization))
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
      console.log("### DEBUG organization", ctrl.organization)
      return MnoeProvisioning.getSubscriptions(limit, offset, sort, ctrl.organization?.id).then(
        (response) ->
          console.log("### DEBUG response", response)
          ctrl.subscriptions.totalItems = response.headers('x-total-count')
          ctrl.subscriptions.list = response.data
          ctrl.subscriptions.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
      ).finally(-> ctrl.subscriptions.loading = false)

    return
})
