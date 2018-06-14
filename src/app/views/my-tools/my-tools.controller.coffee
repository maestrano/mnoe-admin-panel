@App.controller 'MyToolsController', ($uibModal,$state, MnoeMarketplace, MnoeApps, MnoeTenant, MnoConfirm, MnoeCurrentUser, UserRoles) ->
  'ngInject'
#  vm = this
#
#  vm.enabledApps = []
#  vm.filteredApps = []
#  vm.selectedCategory = ''
#  vm.searchTerm = ''
#  vm.tenantPurchasable = "tenant_purchasable"
#  vm.tenantManagement = false
#  # TODO: Use Tenant's organization id here based on MNOE-1187
#  vm.organizationId = 1
#  # Filter apps by name or category
#  vm.onSearchChange = () ->
#    vm.selectedCategory = ''
#    term = vm.searchTerm.toLowerCase()
#    vm.filteredApps = (app for app in vm.enabledApps when app.name.toLowerCase().indexOf(term) isnt -1)
#
#  vm.onCategoryChange = () ->
#    vm.searchTerm = ''
#    if (vm.selectedCategory?.length > 0)
#      vm.filteredApps = (app for app in vm.enabledApps when vm.selectedCategory in app.categories)
#    else
#      vm.filteredApps = vm.enabledApps
#
#  resetFilteredApps = () ->
#    MnoeMarketplace.getApps(vm.tenantPurchasable).then(
#      (response) ->
#        vm.enabledApps = angular.copy(response.data.apps)
#        vm.selectedCategory = ''
#        vm.searchTerm = ''
#        vm.filteredApps = vm.enabledApps
#    )
#
#  vm.openRemoveAppModal = (app, $index)->
#    MnoConfirm.showModal(
#      headerText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.proceed'
#      bodyText: 'mnoe_admin_panel.dashboard.settings.apps.modal.remove_app.perform'
#      bodyTextExtraData: {app_name: app.name}
#      type: 'danger'
#      actionCb: ->
#        MnoeApps.disable(app.id).then(
#          ->
#            resetFilteredApps()
#        )
#    )
#
#  # ====================================
#  # App Info modal
#  # ====================================
#  vm.openInfoModal = (app) ->
#    $uibModal.open(
#      templateUrl: 'app/views/settings/apps/modals/app-infos.html'
#      controller: 'appInfoCtrl'
#      controllerAs: 'vm',
#      size: 'lg'
#      resolve:
#        app: app
#    )
#
#  vm.openSelectProductModal = () ->
#    modalInstance = $uibModal.open(
#      component: 'mnoProductSelectorModal'
#      backdrop: 'static'
#      size: 'lg'
#      resolve:
#        dataFlag: -> 'organization-create-order'
#        isTenantPurchasable : -> true
#        multiple: -> false
#    )
#    modalInstance.result.then(
#      (product) ->
#        $state.go('dashboard.provisioning.order', {productId: product.id, orgId: vm.organizationId, editAction: 'new'})
#    )
#
#
#  # Load config from the Tenant
#  init = ->
#    MnoeMarketplace.getApps(vm.tenantPurchasable).then(
#      (response) ->
#        # Copy the marketplace as we will work on the cached object
#        vm.enabledApps = angular.copy(response.data.apps)
#        vm.filteredApps = vm.enabledApps
#        vm.categories = angular.copy(response.data.categories)
#        vm.displayCategories = vm.categories.length > 0
#    )
#    MnoeTenant.get().then(
#      (response) ->
#        vm.tenantManagement = response.data.app_management == "tenant")
#
#    MnoeCurrentUser.getUser().then(
#      (response) ->
#        vm.isAccountManager = UserRoles.isAccountManager(response)
#    )
#
#  init()
#
  return
