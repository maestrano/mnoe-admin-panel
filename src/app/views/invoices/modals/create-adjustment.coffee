@App.controller 'CreateAdjustmentController', ($uibModalInstance) ->
  'ngInject'
  vm = this

  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.createAdjustment = () ->
    vm.isLoading = true

  return
