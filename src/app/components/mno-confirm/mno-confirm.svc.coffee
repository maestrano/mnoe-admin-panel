@App.service 'MnoConfirm', ($q, $uibModal) ->
  _self = this

  modalOptions =
    closeButtonText: 'mnoe_admin_panel.dashboard.mno_confirm.close'
    closeButtonTextExtraData: {}
    actionButtonText: 'mnoe_admin_panel.dashboard.mno_confirm.ok'
    actionButtonTextExtraData: {}
    headerText: 'mnoe_admin_panel.dashboard.mno_confirm.proceed'
    headerTextExtraData: {}
    bodyText: 'mnoe_admin_panel.dashboard.mno_confirm.perform'
    bodyTextExtraData: {}
    inputTextEnabled: false
    inputTextValue: ''
    inputTextPlaceholder: ''
    actionCb: $q.resolve
    type: 'primary'

  modalDefaults =
    backdrop: true
    keyboard: true
    modalFade: true
    templateUrl: 'app/components/mno-confirm/mno-confirm.html'

  @showModal = (customModalOptions, customModalDefaults = null) ->
    if !customModalDefaults?
      customModalDefaults = {}
    customModalDefaults.backdrop = 'static'
    _self.show(customModalOptions, customModalDefaults)

  @show = (customModalOptions, customModalDefaults = null) ->
    # Create temp objects to work with since we're in a singleton service
    tempModalDefaults = {}
    tempModalOptions = {}

    # Map modal.html $scope custom properties to defaults defined in service
    angular.extend tempModalOptions, modalOptions, customModalOptions

    # Map angular-ui modal custom defaults to modal defaults defined in service
    angular.extend tempModalDefaults, modalDefaults, customModalDefaults

    if !tempModalDefaults.controller
      tempModalDefaults.controller = ($scope, $uibModalInstance) ->
        'ngInject'

        $scope.modalOptions = tempModalOptions

        $scope.modalOptions.ok = () ->
          $scope.modalOptions.isLoading = true
          $scope.modalOptions.actionCb($scope.modalOptions.inputTextValue).then(
            (response) ->
              $uibModalInstance.close(response)
          ).finally(-> $scope.modalOptions.isLoading = false)

        $scope.modalOptions.close = () ->
          $uibModalInstance.dismiss('cancel')

    $uibModal.open(tempModalDefaults).result

  return @
