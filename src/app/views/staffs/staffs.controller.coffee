@App.controller 'StaffsController', ($filter, $stateParams, $uibModal) ->
  'ngInject'
  vm = this

  vm.staff =
    # Display staff creation modal
    createModal: ->
      $uibModal.open(
        templateUrl: 'app/views/staffs/create-staff-modal/create-staff.html'
        controller: 'CreateStaffController'
        controllerAs: 'vm'
      )

  vm.displayed = []

  vm.callServer = ->
    vm.isLoading = false

  return vm
