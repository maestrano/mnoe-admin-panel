@App.controller 'ProductMarkupsController', ($filter, $stateParams, $uibModal) ->
  'ngInject'
  vm = this

  vm.markup =
  # Display markupcreation modal
    createModal: ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/product-markups/create-markup-modal/create-markup.html'
        controller: 'CreateMarkupController'
        controllerAs: 'vm'
      )
    displayInfo: ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/product-markups/markup-info-modal/markup-info.html'
        controller: 'MarkupInfoController'
        controllerAs: 'vm'
      )

  return
