@App.controller 'StaffsController', ($filter, $stateParams, $uibModal, MnoeAdminConfig) ->
  'ngInject'
  vm = this

  vm.isStaffReadOnly = MnoeAdminConfig.isStaffReadOnly()

  vm.staff =
    # Display staff creation modal
    createModal: ->
      $uibModal.open(
        templateUrl: 'app/views/staffs/create-staff-modal/create-staff.html'
        controller: 'CreateStaffController'
        controllerAs: 'vm'
      )

  return vm
