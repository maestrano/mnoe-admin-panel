@App.controller 'SettingsAppsController', ($uibModal, MnoeMarketplace, MnoeApps, MnoConfirm) ->
  'ngInject'
  vm = this

  vm.enabledApps = []

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

  # TODO: cache full list and only apply filtering when resolving
  vm.availableAppsList = () ->
    MnoeApps.list().then(
      (response) ->
        enabledIds = _.map(vm.enabledApps, 'id')
        _.remove(response.data, (app)-> _.includes(enabledIds, app.id))
        return response
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
        # TODO: do we need copy?
        # Copy the marketplace as we will work on the cached object
        vm.enabledApps = angular.copy(response.data.apps)
    )

  init()

  return
