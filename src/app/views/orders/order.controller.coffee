@App.controller 'OrderController', ($filter, $state, $stateParams, toastr, MnoeProvisioning, MnoeOrganizations, MnoeUsers) ->
  'ngInject'
  vm = this

  vm.orderId = $stateParams.orderId
  vm.orgId = $stateParams.orgId

  vm.order = {}
  vm.organization = {}
  vm.user = {}
  vm.fulfillment_status = [{value: 'Y', text: 'mnoe_admin_panel.dashboard.order.fulfillment_yes'},
    {value: 'N', text: 'mnoe_admin_panel.dashboard.order.fulfillment_no'}]

  # Get the organization
  MnoeProvisioning.fetchSubscription(vm.orderId, vm.orgId).then(
    (response) ->
      vm.order = response.data.plain()
      if vm.order.status == "fulfilled"
        vm.fulfillment = "Y"
      else
        vm.fulfillment = "N"

      console.log(vm.order)
      vm.getInfo()
  )

  vm.getInfo = ->
    MnoeOrganizations.get(vm.orgId).then(
      (response) ->
        vm.organization = response.data.plain()
    )
    if vm.order.user_id?
      MnoeUsers.get(vm.order.user_id).then(
        (response) ->
          vm.user = response.data.plain()
      )

  return vm
