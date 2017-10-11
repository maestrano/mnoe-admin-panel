#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter, $log, $translate, MnoeOrganizations, MnoeAdminConfig, MnoeCurrentUser, MnoeObservables, OBS_KEYS) ->
  restrict: 'E',
  scope: {
    filterParams: '='
  },
  templateUrl: 'app/components/mnoe-organizations-list/mnoe-organizations-list.html',
  link: (scope, elem) ->

    # Variables initialization
    scope.organizations =
      search: ''
      sortAttr: 'created_at'
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.organizations.nbItems = nbItems
        scope.organizations.page = page
        offset = (page  - 1) * nbItems
        fetchOrganizations(nbItems, offset, scope.organizations.sortAttr)

    # table generation - need to get the locale first
    $translate(
      ["mnoe_admin_panel.dashboard.organization.account_frozen_state",
      "mnoe_admin_panel.dashboard.organization.widget.list.table.creation",
      'mnoe_admin_panel.dashboard.organization.widget.list.table.name'
      'mnoe_admin_panel.dashboard.organization.widget.list.table.revenue',
      'mnoe_admin_panel.dashboard.organization.widget.list.table.margin'
      'mnoe_admin_panel.dashboard.organization.widget.list.table.currency'])
      .then((locale) ->
        # create the fields for the sortable-table
        basicFields = [
          # organization name
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.name']
          attr: 'name'
          skip_natural: true
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
            scope: {organization: organization}}

          # organization creation date
          { header: locale["mnoe_admin_panel.dashboard.organization.widget.list.table.creation"],
          style: {width: '110px'},
          attr:'created_at',
          sort_default: "reverse"
          skip_natural: true
          render: (organization) ->
            template:
              "<span>{{::organization.created_at | date: 'dd/MM/yyyy'}}</span>"
            scope: {organization: organization}}
        ]

        # Add Finance columns if enabled
        scope.organizations.fields = unless MnoeAdminConfig.isFinanceEnabled() then basicFields else basicFields.concat([
          # Revenue
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.revenue'],
          attr:'financial_metrics.revenue', doNotSort: true, style: width: '110px',}
          # Margin
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.margin'],
          attr:'financial_metrics.margin', doNotSort: true,  style: width: '110px'}
          # Currency
          { header: locale['mnoe_admin_panel.dashboard.organization.widget.list.table.currency'],
          attr:'financial_metrics.currency', doNotSort: true, style: width: '110px'}])
      )

    # Smart table callback
    scope.pipe = (tableState) ->
      # The order has changed - reset pagination
      scope.organizations.page = 1
      scope.organizations.sortAttr = tableState.sort.predicate
      if tableState.sort.reverse
        scope.organizations.sortAttr += ".desc"
      fetchOrganizations(scope.organizations.nbItems, 0, scope.organizations.sortAttr)

    # Fetch organisations
    fetchOrganizations = (limit, offset, sort = 'created_at') ->
      scope.organizations.loading = true
      MnoeCurrentUser.getUser().then( ->
        params = scope.filterParams || {}
        return MnoeOrganizations.list(limit, offset, sort, params).then(
          (response) ->
            scope.organizations.totalItems = response.headers('x-total-count')
            scope.organizations.list = response.data
        ).finally(-> scope.organizations.loading = false)
      )

    displayCurrentState = () ->
      setAllOrganizationsList()
      fetchOrganizations(scope.organizations.nbItems, 0, scope.organizations.sortAttr)

    # Display all the organisations
    setAllOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.all_organizations.title'
      scope.organizations.switchLinkTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.all_users.switch_link_title'

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
      params = scope.filterParams || {}
      MnoeOrganizations.search(terms, params).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = $filter('orderBy')(response.data, 'name')
      ).finally(-> scope.organizations.loading = false)

    onOrganizationChanged = ->
      displayCurrentState()

    # Notify me if Organization are changed
    MnoeObservables.registerCb(OBS_KEYS.organizationChanged, onOrganizationChanged)

    this.$onDestroy = ->
      MnoeObservables.unsubscribe(OBS_KEYS.organizationChanged, onOrganizationChanged)


    # Initial call
    displayCurrentState()
)
