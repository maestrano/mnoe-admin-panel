#
# Mnoe Organizations List
# The organization-local-list is on the user's info page and shows the organizations attached to a user, while
# the organizations-list is on the homepage and shows all the users.

@App.directive('mnoeOrganizationsLocalList', ($translate, $filter, $log, toastr, UserRoles, MnoeUsers, MnoeCurrentUser) ->
  restrict: 'E'
  scope: {
    list: '=',
    user: '='
  },
  templateUrl: 'app/components/mnoe-organizations-local-list/mnoe-organizations-local-list.html',
  link: (scope, elem, attrs) ->
    # Only display some info in the context of an user
    scope.userContext = attrs.user?
    scope.userRoles = UserRoles
    # Variables initialization
    scope.organizations =
      displayList: []
      widgetTitle: 'mnoe_admin_panel.dashboard.organization.widget.local_list.loading_orgs.title'
      search: ''

    MnoeCurrentUser.getUser().then(
      (response) ->
        scope.isSupportManager = UserRoles.isSupportManager(response)
        scope.supportDisabledClass = UserRoles.supportDisabledClass(response)
    )

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

    scope.editRole = (organization) ->
      return if scope.isSupportManager
      # Keep track of old roles when editing organization's roles.
      organization.beforeEditRole = organization.role
      organization.editMode = true

    scope.exitEditRole = (organization) ->
      return if scope.isSupportManager
      organization.role = organization.beforeEditRole
      organization.editMode = false

    scope.updateUserRole = (organization, user) ->
      return if scope.isSupportManager
      user.isUpdatingRole = true
      # The role must be set on the user for #updateUserRole.
      user.role = organization.role
      MnoeUsers.updateUserRole(organization, user).then(
        () ->
          $translate(UserRoles.keyFromRole(user.role)).then((tls) ->
            toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.role_update_success', {extraData: {user: "#{user.email}", role: tls}})
          )
        (error) ->
          organization.role = organization.beforeEditRole
          toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.role_update_error')
          MnoErrorsHandler.processServerError(error)
      ).finally( () ->
        # So that the organization/user reverts back to non-editing view.
        organization.beforeEditRole = null
        organization.isUpdatingRole = false
        organization.editMode = false
      )

    scope.$watch('list', (newVal) ->
      if newVal
        displayNormalState()
    , true)
)
