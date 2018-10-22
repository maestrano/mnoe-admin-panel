@App.directive('mnoeSupportOrganizationsList', ($filter, $translate, $state, MnoeOrganizations, MnoeCurrentUser, MnoeUsers, MnoeAdminConfig) ->
  restrict: 'E',
  scope: {
    filterParams: '='
  },
  templateUrl: 'app/components/mnoe-support/support-organizations-list.html',
  link: (scope, elem) ->

    scope.isSupportRoleEnabled = MnoeAdminConfig.isSupportRoleEnabled()

    # Variables initialization
    scope.organizations =
      externalIdSearch: ''
      orgNameSearch: ''
      firstNameSearch: ''
      lastNameSearch: ''
      list: []

    scope.noResultsFound = () ->
      _.isEmpty(scope.organizations.list)

    MnoeCurrentUser.getUser().then(() ->
      scope.user = MnoeCurrentUser.user
    )

    scope.accessOrganizationInfo = (organization) ->
      MnoeUsers.loginSupport(scope.user, organization.external_id).then(() ->
        scope.$emit('refreshDashboardLayoutSupport')
        $state.go('dashboard.customers.organization', { orgId: organization.id })
      )

    # table generation - need to get the locale first
    $translate(
      ["mnoe_admin_panel.dashboard.organization.account_frozen_state",
      "mnoe_admin_panel.dashboard.organization.widget.list.table.creation",
      'mnoe_admin_panel.dashboard.organization.widget.list.table.name',
      "mnoe_admin_panel.dashboard.organization.demo_account_state"])
      .then((locale) ->
        # create the fields for the sortable-table
        scope.organizations.fields = [
          # organization name
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.name']
          attr: 'name'
          doNotSort: true
          render: (organization) ->
            template: """
              <a ui-sref="dashboard.customers.organization({orgId: organization.id})">
                {{::organization.name}}
                <em ng-show="organization.account_frozen" class="text-muted" translate>
                mnoe_admin_panel.dashboard.organization.account_frozen_state</em>
                <em ng-show="organization.demo_account" class="text-muted" translate>
                mnoe_admin_panel.dashboard.organization.demo_account_state</em>
              </a>
            """,
            scope: {
              organization: organization
              }
            }

          # organization creation date
          { header: locale["mnoe_admin_panel.dashboard.organization.widget.list.table.creation"],
          style: {width: '110px'},
          attr:'created_at',
          doNotSort: true
          render: (organization) ->
            template:
              "<span>{{::organization.created_at | date: 'dd/MM/yyyy'}}</span>"
            scope: {organization: organization}}
        ]
      )

    scope.externalIdSearch = () ->
      return unless scope.organizations.externalIdSearch.length > 2
      # Reset other search fields.
      scope.organizations.orgNameSearch = ''
      scope.organizations.firstNameSearch = ''
      scope.organizations.lastNameSearch = ''
      setSearchOrganizationsList()

    scope.nameSearch = () ->
      org = scope.organizations
      return unless org.orgNameSearch.length >= 2 && org.firstNameSearch.length >= 2 && org.lastNameSearch.length >= 2
      # Reset other search field.
      scope.organizations.externalIdSearch = ''
      setSearchOrganizationsList()

    scope.noResultsText = if scope.isSupportRoleEnabled
      "mnoe_admin_panel.dashboard.organization.widget.list.suport.search_users.no_results"
    else
      "mnoe_admin_panel.dashboard.organization.widget.list.suport.search_users.support_role_disabled"

    # Display only the search results
    setSearchOrganizationsList = () ->
      scope.organizations.loading = true

      params = {
        org_search: {
          where: {
            external_id: scope.organizations.externalIdSearch
          }
        }
      }

      MnoeOrganizations.supportSearch(params).then((response) ->
        scope.organizations.list = $filter('orderBy')(response.data.organizations, 'created_at')
      ).finally(-> scope.organizations.loading = false)

)
