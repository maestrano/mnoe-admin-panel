#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter, $log, $translate, MnoeOrganizations, MnoeAdminConfig, MnoeCurrentUser) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-organizations-list/mnoe-organizations-list.html',
  link: (scope, elem, attrs) ->

    # Widget state
    scope.state = attrs.view
    # Variables initialization
    scope.organizations =
      search: ''
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.organizations.nbItems = nbItems
        scope.organizations.page = page
        offset = (page  - 1) * nbItems
        fetchOrganizations(nbItems, offset)

    $translate(["mnoe_admin_panel.dashboard.organization.account_frozen_state",
      "mnoe_admin_panel.dashboard.organization.widget.list.table.creation",
      'mnoe_admin_panel.dashboard.organization.widget.list.table.name'
      'mnoe_admin_panel.dashboard.organization.widget.list.table.revenue',
      'mnoe_admin_panel.dashboard.organization.widget.list.table.margin'
      'mnoe_admin_panel.dashboard.organization.widget.list.table.currency']).then((locale) ->
        basicFields = [
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.name']
          attr: 'name'
          skip_natural: true
          render: (organization) ->
            template: """
              <a ui-sref="dashboard.customers.organization({orgId: organization.id})">
                {{::organization.name}}
                <em ng-show="organization.account_frozen" class="text-muted" translate>
                mnoe_admin_panel.dashboard.organization.account_frozen_state</em>
              </a>
            """,
            scope: {organization: organization} }
          { header: locale["mnoe_admin_panel.dashboard.organization.widget.list.table.creation"],
          style: {width: '110px'},
          attr:'created_at',
          sort_default: "reverse"
          skip_natural: true
          render: (organization) ->
            template:
              "<span>{{::organization.created_at | date: 'dd/MM/yyyy'}}</span>"
            scope: {organization: organization}}]
        scope.organizations.fields = unless MnoeAdminConfig.isFinanceEnabled() then basicFields else basicFields.concat(
          [{ header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.revenue'],
          skip_natural: true, attr:'financial_metrics.revenue', style: width: '110px',}
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.margin'],
          skip_natural: true, attr:'financial_metrics.margin',  style: width: '110px'}
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.currency'],
          skip_natural: true, attr: 'financial_metrics.currency', style: width: '110px'}]))

    # Fetch organisations
    fetchOrganizations = (limit, offset, sort = 'name') ->
      scope.organizations.loading = true
      MnoeCurrentUser.getUser().then( ->
        params = {sub_tenant_id: MnoeCurrentUser.user.mnoe_sub_tenant_id, account_manager_id: MnoeCurrentUser.user.id}
        return MnoeOrganizations.list(limit, offset, sort, params).then(
          (response) ->
            scope.organizations.totalItems = response.headers('x-total-count')
            scope.organizations.list = response.data
        ).finally(-> scope.organizations.loading = false)
      )

    scope.switchState = () ->
      scope.state = attrs.view = if attrs.view == 'all' then 'last' else 'all'
      displayCurrentState()

    # if view="all" is set on the directive, all the users are displayed
    # if view="last" is set on the directive, the last 10 users are displayed
    displayCurrentState = () ->
      if attrs.view == 'all'
        setAllOrganizationsList()
        fetchOrganizations(scope.organizations.nbItems, 0)
      else if attrs.view == 'last'
        setLastOrganizationsList()
        fetchOrganizations(scope.organizations.nbItems, 0, 'created_at.desc')
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    # Display all the organisations
    setAllOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.all_organizations.title'
      scope.organizations.switchLinkTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.all_users.switch_link_title'

    # Display only the last 10 organisations
    setLastOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.last_organizations.title'
      scope.organizations.switchLinkTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.last_organizations.switch_link_title'

    scope.searchChange = () ->
      # Only search if the string is >= than 3 characters
      if scope.organizations.search.length >= 3
        scope.searchMode = true
        setSearchOrganizationsList(scope.organizations.search)
      # No search string, so display current state
      else if scope.searchMode
        scope.searchMode = false
        displayCurrentState()

    # Display only the search results
    setSearchOrganizationsList = (search) ->
      scope.organizations.loading = true
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.search_users.title'
      delete scope.organizations.switchLinkTitle
      search = scope.organizations.search.toLowerCase()
      terms = {'name.like': "%#{search}%"}
      MnoeOrganizations.search(terms).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = $filter('orderBy')(response.data, 'name')
      ).finally(-> scope.organizations.loading = false)

    # Initial call
    displayCurrentState()
)
