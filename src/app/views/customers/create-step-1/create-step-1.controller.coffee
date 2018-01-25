@App.controller 'CreateStep1Controller', ($scope, $document, $state, toastr, MnoeAdminConfig, MnoeOrganizations, MnoeMarketplace, MnoErrorsHandler, MnoeCurrentUser, MnoeSubTenants) ->
  'ngInject'
  vm = this

  vm.organization = {}
  vm.appSearch = ""
  vm.subTenantLoading = true
  vm.isAdmin = false
  vm.selectedSubTenants = {}
  vm.sub_tenants = []

  vm.toggleApp = (app) ->
    app.checked = !app.checked

  vm.submitOrganisation = () ->
    # Is form valid?
    if vm.form.$invalid
      # Check if there is errors that are not from the server
      if !MnoErrorsHandler.onlyServerError(vm.form)
        # Scroll to the top of form
        form = angular.element(document.getElementById('org-form'))
        $document.scrollToElementAnimated(form)
        return

    vm.isLoading = true

    # Reset server errors
    MnoErrorsHandler.resetErrors(vm.form)

    # List of checked apps
    vm.organization.app_nids = _.map(_.filter(vm.marketplace.apps, {checked: true}), 'nid') if MnoeAdminConfig.isAppManagementEnabled()

    vm.organization.sub_tenant_ids = Object.keys vm.selectedSubTenants

    MnoeOrganizations.create(vm.organization).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.customers.create_customer.toastr_success', {extraData: {organization_name: vm.organization.name}})
        response = response.data.plain()
        # App to be connected?
        if _.isEmpty(response.organization.active_apps)
          # Go to organization screen
          $state.go('dashboard.customers.organization', {orgId: response.organization.id})
        else
          # Go to connect your apps screen
          $state.go('dashboard.customers.connect-app', {orgId: response.organization.id})
      (error) ->
        $document.scrollTopAnimated(0)
        toastr.error('mnoe_admin_panel.dashboard.customers.create_customer.toastr_error', {extraData: {organization_name: vm.organization.name}})
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  MnoeMarketplace.getApps().then(
    (response) ->
      # Copy the marketplace as we will work on the cached object
      vm.marketplace = angular.copy(response.data)
  ) if MnoeAdminConfig.isAppManagementEnabled()

  loadSubTenants = ->
    MnoeSubTenants.list(null, null, 'name.desc').then(
      (response) ->
        vm.sub_tenants = response.data
    ).finally(-> vm.subTenantLoading = false)

  MnoeCurrentUser.getUser().then(
    vm.user = MnoeCurrentUser.user
    vm.isAdmin = vm.user.admin_role == 'admin'
    if vm.isAdmin
      loadSubTenants()
    else
      vm.selectedSubTenants[vm.user.mnoe_sub_tenant_id] = true
      vm.subTenantLoading = false
  )

  return
