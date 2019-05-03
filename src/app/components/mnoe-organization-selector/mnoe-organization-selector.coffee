#
# Mnoe Organization Selector
#
# Display the list of Organization available to a staff member and allow to switch between them
# while on the staff dashboard view
#
@App.component('mnoeOrganizationSelector', {
  templateUrl: 'app/components/mnoe-organization-selector/mnoe-organization-selector.html',
  bindings: {
    organizationId: '<'
  }
  controller: ($state, MnoeAdminConfig, MnoeCurrentUser, MnoeOrganizations) ->
    ctrl = this

    ctrl.refreshOrganizations = (search = null) ->
      search = search.toLowerCase()

      # Filtering by Account Manager
      params = if MnoeAdminConfig.isAccountManagerEnabled()
        {sub_tenant_id: MnoeCurrentUser.user.mnoe_sub_tenant_id, account_manager_id: MnoeCurrentUser.user.id}
      else
        {}

      # Search terms
      if search
        params['terms'] = {'name.like': "%#{search}%"}

      args = [30, 0, 'name', params]

      MnoeOrganizations.list(args...).then(
        (response) ->
          ctrl.organizations.totalItems = response.headers('x-total-count')
          ctrl.organizations.list = response.data

          # TODO: refactor this
          # Select organization
          if (orgId = parseInt(ctrl.organizationId))
            ctrl.organizations.selected = ctrl.organizations.list.find((org) -> org.id == orgId)

            # If current organization not available in first page, manually fetch it
            # Unless a search is in progress
            unless ctrl.organizations.selected || search
              MnoeOrganizations.list(
                1, 0, 'name', angular.extend({terms: {id: orgId}}, params)
              ).then(
                (response) ->
                  if (org = response.data[0])
                    ctrl.organizations.list.unshift(org)
                    ctrl.organizations.selected = org
              )
      )

    ctrl.onSelectCallback = (item, _model) ->
      # Display the staff dashboards for the selected company
      $state.go('dashboard.staff-dashboard-show', {orgId: item.id, dashboardId: null})

    # Variables initialization
    ctrl.organizations =
      list: []
      loading: false

    return
})
