@App.controller 'DeleteAdjustmentController', ($uibModalInstance) ->
  'ngInject'
  vm = this

  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.deleteAdjustment = () ->
    vm.isLoading = true

  return
