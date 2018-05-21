@App.controller 'CreateStep1Controller', ($scope, $document, $state, toastr, MnoeAdminConfig, MnoeOrganizations, MnoeMarketplace, MnoErrorsHandler, MnoAppsInstances) ->
  'ngInject'
  vm = this

  vm.organization = {}
  vm.appSearch = ""
  vm.mainAddressRequired = MnoeOrganizations.mainAddressRequired()

  # The app selection is not compatible with the subscription workflow
  vm.showAppsSelection = MnoeAdminConfig.isAppManagementEnabled() && !MnoeAdminConfig.isProvisioningEnabled()

  vm.toggleApp = (app) ->
    app.checked = !app.checked

  vm.hasDisconnectedApps = (apps) ->
    !_.every(apps, (app) -> MnoAppsInstances.isConnected(app))

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
    vm.organization.app_nids = _.map(_.filter(vm.marketplace.apps, {checked: true}), 'nid') if vm.showAppsSelection

    MnoeOrganizations.create(vm.organization).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.customers.create_customer.toastr_success', {extraData: {organization_name: vm.organization.name}})
        response = response.data.plain()
        # App to be connected?
        if _.isEmpty(response.organization.active_apps) || !vm.hasDisconnectedApps(response.organization.active_apps)
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
  ) if vm.showAppsSelection

  return
