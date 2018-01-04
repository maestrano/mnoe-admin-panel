@App.controller 'SettingsAppsController', ($uibModal, MnoeMarketplace, MnoeApps, MnoeTenant, MnoConfirm) ->
  'ngInject'
  vm = this

  vm.enabledApps = []

  vm.tenantManagement = false

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

  vm.availableAppsList = () ->
    MnoeApps.list().then(
      (response) ->
        # Copy the response, we're are modifying the response in place and
        # don't want to modify the cached version in MnoeApps
        resp = angular.copy(response)
        enabledIds = _.map(vm.enabledApps, 'id')
        _.remove(resp.data, (app)-> _.includes(enabledIds, app.id))
        return resp
    )

  vm.openAddAppModal = () ->
    modalInstance = $uibModal.open(
      component: 'mnoProductSelectorModal'
      backdrop: 'static'
      size: 'lg'
      resolve:
        products: -> vm.availableAppsList()
        multiple: -> true
        headerText: -> 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.title'
        actionButtonText: -> 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.add'
    )
    modalInstance.result.then(
      (apps) ->
        MnoeApps.enableMultiple(_.map(apps, 'id')).then(
          ->
            vm.enabledApps = vm.enabledApps.concat(apps)
        )
    )

  # Load config from the Tenant
  init = ->
    MnoeMarketplace.getApps().then(
      (response) ->
        # Copy the marketplace as we will work on the cached object
        vm.enabledApps = angular.copy(response.data.apps)
    )
    MnoeTenant.get().then(
      (response) ->
        vm.tenantManagement = response.data.app_management == "tenant")

  init()

  return
