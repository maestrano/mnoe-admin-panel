@App.controller 'MarkupInfoController', ($filter, $stateParams, $log, $uibModalInstance) ->
  'ngInject'
  vm = this

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
