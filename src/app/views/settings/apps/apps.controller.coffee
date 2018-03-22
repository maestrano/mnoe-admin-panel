@App.controller 'SettingsAppsController', ($uibModal, MnoeMarketplace, MnoeApps, MnoeTenant, MnoConfirm) ->
  'ngInject'
  vm = this

  vm.enabledApps = []
  vm.selectedCategory = ''
  vm.searchTerm = ''

  vm.tenantManagement = false

  vm.appsFilter = (app) ->
    if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory
      return true
    else
      return _.contains(app.categories, vm.selectedCategory)

  vm.openRemoveAppModal = (app, $index)->
    MnoConfirm.showModal(
      headerText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.perform'
      bodyTextExtraData: {app_name: app.name}
      type: 'danger'
      actionCb: ->
        MnoeApps.disable(app.id).then(
          -> vm.enabledApps.splice($index, 1)
        )
    )

  # ====================================
  # App Info modal
  # ====================================
  vm.openInfoModal = (app) ->
    $uibModal.open(
      templateUrl: 'app/views/settings/apps/modals/app-infos.html'
      controller: 'appInfoCtrl'
      controllerAs: 'vm',
      size: 'lg'
      resolve:
        app: app
    )

  vm.openAddAppModal = () ->
    modalInstance = $uibModal.open(
      component: 'mnoProductSelectorModal'
      backdrop: 'static'
      size: 'lg'
      resolve:
        dataFlag: -> 'settings-add-new-app'
        enabledApps: -> vm.enabledApps
        multiple: -> true
        headerText: -> 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.title'
        actionButtonText: -> 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.add'
    )
    modalInstance.result.then(
      (apps) ->
        MnoeApps.enableMultiple(_.map(apps, 'id')).then(
          ->
            MnoeMarketplace.getApps().then(
              (response) ->
                vm.enabledApps = angular.copy(response.data.apps)
            )
        )
    )

  # Load config from the Tenant
  init = ->
    MnoeMarketplace.getApps().then(
      (response) ->
        # Copy the marketplace as we will work on the cached object
        vm.enabledApps = angular.copy(response.data.apps)
        vm.categories = angular.copy(response.data.categories)
        vm.displayCategories = vm.categories.length > 1
    )
    MnoeTenant.get().then(
      (response) ->
        vm.tenantManagement = response.data.app_management == "tenant")

  init()

  return
