#
# Mnoe AppMetrics List
#
@App.directive('mnoeAppMetricsList', ($filter, $log, $translate, MnoeAppMetrics, MnoeAdminConfig) ->
  restrict: 'E'
  scope: {
  }
  templateUrl: 'app/components/mnoe-app-metrics-list/mno-app-metrics-list.html'
  link: (scope, elem, attrs) ->

    # Widget state
    scope.state = attrs.view

    # Variables initialization
    scope.apps =
      search: ''
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.apps.nbItems = nbItems
        scope.apps.page = page
        offset = (page  - 1) * nbItems
        fetchApps(nbItems, offset)

    scope.isFinanceEnabled = MnoeAdminConfig.isFinanceEnabled()

    # Fetch apps
    fetchApps = (limit, offset, sort = 'name') ->
      scope.apps.loading = true
      return MnoeAppMetrics.list(limit, offset, sort).then(
        (response) ->
          scope.apps.totalItems = response.headers('x-total-count')
          scope.apps.list = response.data[0]['app_metrics']
      ).finally(-> scope.apps.loading = false)

    scope.switchState = () ->
      scope.state = attrs.view = if attrs.view == 'all' then 'last' else 'all'
      displayCurrentState()

    # if view="all" is set on the directive, all the apps are displayed
    # if view="last" is set on the directive, the last 10 apps are displayed
    displayCurrentState = () ->
      if attrs.view == 'all'
        setAllAppsList()
        fetchApps(scope.apps.nbItems, 0)
      else if attrs.view == 'last'
        setLastAppsList()
        fetchApps(scope.apps.nbItems, 0, 'running_instances_count.desc')
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    # Display all the apps
    setAllAppsList = () ->
      scope.apps.widgetTitle = 'mnoe_admin_panel.dashboard.apps.widget.list.all_apps.title'
      scope.apps.switchLinkTitle = 'mnoe_admin_panel.dashboard.apps.widget.list.all_apps.switch_link_title'

    # Display only the last 10 apps
    setLastAppsList = () ->
      scope.apps.widgetTitle = 'mnoe_admin_panel.dashboard.apps.widget.list.last_apps.title'
      scope.apps.switchLinkTitle = 'mnoe_admin_panel.dashboard.apps.widget.list.last_apps.switch_link_title'

    scope.searchChange = () ->
      # Only search if the string is >= than 3 characters
      if scope.apps.search.length >= 3
        scope.searchMode = true
        setSearchAppsList(scope.apps.search)
      # No search string, so display current state
      else if scope.searchMode
        scope.searchMode = false
        displayCurrentState()

    # Display only the search results
    setSearchAppsList = (search) ->
      scope.apps.loading = true
      scope.apps.widgetTitle = 'mnoe_admin_panel.dashboard.apps.widget.list.search_apps.title'
      delete scope.apps.switchLinkTitle
      search = scope.apps.search.toLowerCase()
      terms = {'name.like': "#{search}%" }
      MnoeAppMetrics.search(terms).then(
        (response) ->
          scope.apps.totalItems = response.headers('x-total-count')
          scope.apps.list = $filter('orderBy')(response.data[0]['app_metrics'], 'name')
      ).finally(-> scope.apps.loading = false)

    # Initial call
    displayCurrentState()
)
