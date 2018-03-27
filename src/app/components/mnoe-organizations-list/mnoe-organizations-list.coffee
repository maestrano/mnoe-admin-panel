#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter, $log, $window, MnoeOrganizations) ->
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

    listingFilters = (term) ->
      term[ 'account_frozen' ] = false if scope.hideFrozen
      term[ 'demo_account' ] = false if scope.hideDemo

    # Fetch organisations
    fetchOrganizations = (limit, offset, sort = 'name') ->
      scope.organizations.loading = true
      search = {}
      listingFilters(search)
      return MnoeOrganizations.list(limit, offset, sort, search).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = response.data
      ).then(-> scope.organizations.loading = false)

    scope.switchState = () ->
      scope.state = attrs.view = if attrs.view == 'all' then 'last' else 'all'
      displayCurrentState()

    loadDefaultFilters = () ->
      scope.hideFrozen = if $window.sessionStorage.getItem('isFrozen') then $window.sessionStorage.getItem('isFrozen') == 'true' else true
      scope.hideDemo = if $window.sessionStorage.getItem('isDemo') then $window.sessionStorage.getItem('isDemo') == 'true' else true

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

    scope.toggleSearchFilters = (filter) ->
      switch filter
        when 'isDemo'
          scope.hideDemo = !scope.hideDemo
          $window.sessionStorage.setItem(filter, scope.hideDemo)
        when 'isFrozen'
          scope.hideFrozen = !scope.hideFrozen
          $window.sessionStorage.setItem(filter, scope.hideFrozen)
      if scope.searchMode == true
        setSearchOrganizationsList(scope.organizations.search)
      else
        displayCurrentState()

    scope.showFooter = ->
      scope.showListingMessage() || scope.showPagination()

    scope.showListingMessage = ->
      scope.hideDemo || scope.hideFrozen

    scope.showPagination = ->
      scope.organizations.list && scope.state == 'all' && !scope.searchMode

    # Display only the search results
    setSearchOrganizationsList = (search) ->
      scope.organizations.loading = true
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.list.search_users.title'
      delete scope.organizations.switchLinkTitle
      search = scope.organizations.search.toLowerCase()
      terms = {'name.like': "%#{search}%"}
      terms['listing_filters'] = {}
      listingFilters(terms['listing_filters'])
      MnoeOrganizations.search(terms).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = $filter('orderBy')(response.data, 'name')
      ).finally(-> scope.organizations.loading = false)

    # Set session based filters
    loadDefaultFilters()

    # Initial call
    displayCurrentState()
)
