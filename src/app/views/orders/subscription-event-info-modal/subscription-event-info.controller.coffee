@App.controller 'subscriptionEventInfoCtrl', ($uibModalInstance, MnoeAdminConfig, event, subscription) ->
  vm = this
  vm.event = event
  vm.subscription = subscription

  vm.close = ->
    $uibModalInstance.close()

  return
