###
#   @desc Modal used to select one or multiple products
#   @binding {Array} [resolve.products] The list of products to be displayed
#   @binding {Boolean} [resolve.multiple] Is the user allowed to select more than one product?
###
@App.component('mnoePurchasableProductsList', {
  bindings: {
    purchasable: '='
  },
  templateUrl: 'app/components/mnoe-purchasable-products-list/mnoe-purchasable-products-list.html',
  controller: ($state, $uibModal, MnoeMarketplace, MnoeApps, MnoeTenant, MnoConfirm, MnoeAdminApiSvc, MnoeCurrentUser, UserRoles) ->
    'ngInject'

    $ctrl = this
    $ctrl.state = $state
    $ctrl.enabledApps = []
    $ctrl.filteredApps = []
    $ctrl.selectedCategory = ''
    $ctrl.searchTerm = ''
    $ctrl.toolsCheck = "tools"
    $ctrl.tenantManagement = false
    $ctrl.purchasableType = null
  # TODO: Use Tenant's organization id here based on MNOE-1187
    $ctrl.organizationId = 1

    $ctrl.$onInit = ->
      $ctrl.purchasableType = $ctrl.purchasable || null
      init()

  # Filter apps by name or category
    $ctrl.onSearchChange = () ->
      $ctrl.selectedCategory = ''
      term = $ctrl.searchTerm.toLowerCase()
      $ctrl.filteredApps = (app for app in $ctrl.enabledApps when app.name.toLowerCase().indexOf(term) isnt -1)

    $ctrl.onCategoryChange = () ->
      $ctrl.searchTerm = ''
      if ($ctrl.selectedCategory?.length > 0)
        $ctrl.filteredApps = (app for app in $ctrl.enabledApps when $ctrl.selectedCategory in app.categories)
      else
        $ctrl.filteredApps = $ctrl.enabledApps

    resetFilteredApps = () ->
      MnoeMarketplace.getApps($ctrl.purchasableType).then(
        (response) ->
          $ctrl.enabledApps = angular.copy(response.data.apps)
          $ctrl.selectedCategory = ''
          $ctrl.searchTerm = ''
          $ctrl.filteredApps = $ctrl.enabledApps
      )

    $ctrl.openRemoveAppModal = (app, $index)->
      MnoConfirm.showModal(
        headerText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.proceed'
        bodyText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.perform'
        bodyTextExtraData: {app_name: app.name}
        type: 'danger'
        actionCb: ->
          MnoeApps.disable(app.id).then(
            ->
              resetFilteredApps()
          )
      )

  # ====================================
  # App Info modal
  # ====================================
    $ctrl.openInfoModal = (app) ->
      $uibModal.open(
        templateUrl: 'app/views/settings/apps/modals/app-infos.html'
        controller: 'appInfoCtrl'
        controllerAs: 'vm',
        size: 'lg'
        resolve:
          app: app
      )

    $ctrl.openAddAppModal = () ->
      resolve = {
        dataFlag: -> 'settings-add-new-app'
        enabledApps: -> $ctrl.enabledApps
        purchasableType: -> $ctrl.purchasableType
        isTenantPurchasable: -> if $ctrl.purchasableType == 'tenant_purchasable' then true else false
        multiple : -> if $ctrl.purchasableType == 'tenant_purchasable' then false else true
        headerText : -> if $ctrl.purchasableType == 'tenant_purchasable' then '' else 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.title'
        actionButtonText : -> 'mnoe_admin_panel.dashboard.settings.apps.modal.add_app.add'
      }
      modalInstance = $uibModal.open(
        component: 'mnoProductSelectorModal'
        backdrop: 'static'
        size: 'lg'
        resolve: resolve
      )
      modalInstance.result.then(
        (response) ->
          switch $ctrl.purchasableType
            when "tenant_purchasable"
              $state.go('dashboard.provisioning.order', {productId: response.id, orgId: $ctrl.organizationId, editAction: 'new'})
            when "user_purchasable"
              MnoeApps.enableMultiple(_.map(response, 'id')).then(
                ->
                  resetFilteredApps()
              )
      )
  # Load config from the Tenant
    init = ->
      callUrl=''
      switch $ctrl.purchasableType
        when "tenant_purchasable"
          params = { 'organization_id' : $ctrl.organizationId }
          callUrl = MnoeApps.subscribedTenantAppsList(params)
        when "user_purchasable"
          callUrl = MnoeMarketplace.getApps($ctrl.purchasableType)
      callUrl.then(
        (response) ->
  # Copy the marketplace as we will work on the cached object
          $ctrl.enabledApps = angular.copy(response.data.apps)
          $ctrl.filteredApps = $ctrl.enabledApps
          $ctrl.categories = angular.copy(response.data.categories || null)
          $ctrl.displayCategories = if $ctrl.categories then $ctrl.categories.length > 0 else false
      )
      MnoeTenant.get().then(
        (response) ->
          $ctrl.tenantManagement = response.data.app_management == "tenant")

      MnoeCurrentUser.getUser().then(
        (response) ->
          $ctrl.isAccountManager = UserRoles.isAccountManager(response)
      )
    return
})
