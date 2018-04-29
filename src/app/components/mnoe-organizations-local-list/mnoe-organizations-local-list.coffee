#
# Mnoe Organizations Local List
# The organization-local-list is used for organizations that already exist on the frontend, e.g. when uploading a CSV file.
# Whereas organizations-list is used when organizations must be fetched.
#
@App.directive('mnoeOrganizationsLocalList', ($filter, $log) ->
  restrict: 'E'
  scope: {
    list: '=',
  },
  templateUrl: 'app/components/mnoe-organizations-local-list/mnoe-organizations-local-list.html',
  link: (scope, elem, attrs) ->

    # Variables initialization
    scope.organizations =
      displayList: []
      widgetTitle: 'mnoe_admin_panel.dashboard.organization.widget.local_list.loading_orgs.title'
      search: ''

    # Display all the organizations
    setAllOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.local_list.all_organizations.title'
      scope.organizations.switchLinkTitle = 'mnoe_admin_panel.dashboard.organization.widget.local_list.all_organizations.switch_link_title'
      scope.organizations.displayList = $filter('orderBy')(scope.list, 'email')

    # Display only the last 10 organizations
    setLastOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.local_list.last_organizations.title'
      scope.organizations.switchLinkTitle = 'mnoe_admin_panel.dashboard.organization.widget.local_list.last_organizations.switch_link_title'
      scope.organizations.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.organizations.displayList = $filter('limitTo')(scope.organizations.displayList, 10)

    # Display only the search results
    setSearchOrganizationsList = () ->
      scope.organizations.widgetTitle = 'mnoe_admin_panel.dashboard.organization.widget.local_list.search_organizations.title'
      delete scope.organizations.switchLinkTitle
      searchToLowerCase = scope.organizations.search.toLowerCase()
      scope.organizations.displayList = _.filter(scope.list, (user) ->
        email = _.contains(user.email.toLowerCase(), searchToLowerCase) if user.email
        name = _.contains(user.name.toLowerCase(), searchToLowerCase) if user.name
        surname = _.contains(user.surname.toLowerCase(), searchToLowerCase) if user.surname
        (email || name || surname)
      )
      scope.organizations.displayList = $filter('orderBy')(scope.organizations.displayList, 'email')

    displayNormalState = () ->
      # if view="all" is set on the directive, all the organizations are displayed
      # if view="last" is set on the directive, the last 10 organizations are displayed
      if attrs.view == 'all'
        setAllOrganizationsList()
      else if attrs.view == 'last'
        setLastOrganizationsList()
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    scope.switchState = () ->
      if attrs.view == 'all'
        attrs.view = 'last'
      else
        attrs.view = 'all'
      displayNormalState()

    scope.searchChange = () ->
      if scope.organizations.search == ''
        displayNormalState()
      else
        setSearchOrganizationsList()

    scope.$watch('list', (newVal) ->
      if newVal
        displayNormalState()
    , true)
)
