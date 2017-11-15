#
# Mnoe Users List
#
@App.directive('mnoeUsersList', ($filter, $log, $translate, MnoeUsers, MnoeCurrentUser) ->
  restrict: 'E'
  scope: {
  }
  templateUrl: 'app/components/mnoe-users-list/mno-users-list.html'
  link: (scope, elem, attrs) ->

    # Widget state
    scope.state = attrs.view

    # Variables initialization
    scope.users =
      search: ''
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.users.nbItems = nbItems
        scope.users.page = page
        offset = (page  - 1) * nbItems
        fetchUsers(nbItems, offset)

    $translate(["mnoe_admin_panel.dashboard.users.widget.list.table.created_at",
      'mnoe_admin_panel.dashboard.users.widget.list.table.username',
      'mnoe_admin_panel.dashboard.users.widget.list.table.never',
      'mnoe_admin_panel.dashboard.users.widget.list.table.last_login']).then((locale) ->
        scope.users.fields = [
          { header: locale['mnoe_admin_panel.dashboard.users.widget.list.table.username']
          attr: "surname"
          render: (user) ->
            template: """
            <a ui-sref="dashboard.customers.user({userId: user.id})">
              <div ng-show="user.name && user.surname">{{::user.name}} {{::user.surname}}</div>
              <div ng-show="!user.name && !user.surname">zzz</div>
              <small>{{::user.email}}</small>
            </a>
            """,
            scope: { user: user }
          skip_natural: true}
          { header: locale['mnoe_admin_panel.dashboard.users.widget.list.table.last_login']
          attr: "last_sign_in_at"
          style: {width: "130px"}
          render: (user) ->
            template: """
            <span data-toggle="tooltip" title="{{::user.last_sign_in_at | date: 'H:m - dd/MM/yyyy'}}">
              {{(user.last_sign_in_at | amTimeAgo) || ('mnoe_admin_panel.dashboard.users.widget.list.never' | translate)}}
            </span>
            """,
            scope: {user: user}
          skip_natural: true}
          { header: locale["mnoe_admin_panel.dashboard.users.widget.list.table.created_at"],
          style: {width: '130px'},
          attr:'created_at',
          sort_default: "reverse"
          skip_natural: true
          render: (user) ->
            template:
              "<span>{{::user.created_at | date: 'dd/MM/yyyy'}}</span>"
            scope: {user: user}}])

    # Fetch users
    fetchUsers = (limit, offset, sort = 'surname') ->
      scope.users.loading = true
      MnoeCurrentUser.getUser().then( ->
        params = {sub_tenant_id: MnoeCurrentUser.user.mnoe_sub_tenant_id, account_manager_id: MnoeCurrentUser.user.id}
        return MnoeUsers.list(limit, offset, sort, params).then(
          (response) ->
            scope.users.totalItems = response.headers('x-total-count')
            scope.users.list = response.data
            $log.log scope.users.list
        ).finally(-> scope.users.loading = false)
      )

    scope.switchState = () ->
      scope.state = attrs.view = if attrs.view == 'all' then 'last' else 'all'
      displayCurrentState()

    # if view="all" is set on the directive, all the users are displayed
    # if view="last" is set on the directive, the last 10 users are displayed
    displayCurrentState = () ->
      if attrs.view == 'all'
        setAllUsersList()
        fetchUsers(scope.users.nbItems, 0)
      else if attrs.view == 'last'
        setLastUsersList()
        fetchUsers(10, 0, 'created_at.desc')
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    # Display all the users
    setAllUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.list.all_users.title'
      scope.users.switchLinkTitle = 'mnoe_admin_panel.dashboard.users.widget.list.all_users.switch_link_title'

    # Display only the last 10 users
    setLastUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.list.last_users.title'
      scope.users.switchLinkTitle = 'mnoe_admin_panel.dashboard.users.widget.list.last_users.switch_link_title'

    scope.searchChange = () ->
      # Only search if the string is >= than 3 characters
      if scope.users.search.length >= 3
        scope.searchMode = true
        setSearchUsersList(scope.users.search)
      # No search string, so display current state
      else if scope.searchMode
        scope.searchMode = false
        displayCurrentState()

    # Display only the search results
    setSearchUsersList = (search) ->
      scope.users.loading = true
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.list.search_users.title'
      delete scope.users.switchLinkTitle
      search = scope.users.search.toLowerCase()
      terms = {'surname.like': "#{search}%", 'name.like': "#{search}%", 'email.like': "%#{search}%" }
      MnoeUsers.search(terms).then(
        (response) ->
          scope.users.totalItems = response.headers('x-total-count')
          scope.users.list = $filter('orderBy')(response.data, 'email')
      ).finally(-> scope.users.loading = false)

    # Initial call
    displayCurrentState()
)
