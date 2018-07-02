#
# Mnoe Users List
#
@App.directive('mnoeUsersList', ($filter, $translate, MnoeAdminConfig, MnoeUsers, MnoeCurrentUser) ->
  restrict: 'E'
  scope: {
    filterParams: '='
  }
  templateUrl: 'app/components/mnoe-users-list/mno-users-list.html'
  link: (scope, elem) ->

    # Variables initialization
    scope.users =
      search: ''
      sortAttr: 'created_at'
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.users.nbItems = nbItems
        scope.users.page = page
        offset = (page  - 1) * nbItems
        fetchUsers(nbItems, offset, scope.users.sortAttr)

    # table generation - need to get the locale first
    $translate([
      "mnoe_admin_panel.dashboard.users.widget.list.table.created_at",
      'mnoe_admin_panel.dashboard.users.widget.list.table.username',
      "mnoe_admin_panel.dashboard.users.widget.list.table.uid",
      "mnoe_admin_panel.dashboard.users.widget.list.table.external_id",
      "mnoe_admin_panel.dashboard.users.widget.list.table.last_active_at",
      'mnoe_admin_panel.dashboard.users.widget.list.never',
      'mnoe_admin_panel.dashboard.users.widget.list.table.last_login'])
      .then((locale) ->
        # create the fields for the sortable-table
        scope.users.fields = [
          # User name, surname, and email
          { header: locale['mnoe_admin_panel.dashboard.users.widget.list.table.username']
          attr: "surname"
          render: (user) ->
            template: """
            <a ui-sref="dashboard.customers.user({userId: user.id})">
              <div>
                <span ng-show="user.name && user.surname">{{::user.name }} {{::user.surname}}</span>
                <span ng-show="!user.name && !user.surname">nc</span>
                <i title="{{ mnoe_admin_panel.dashboard.users.widget.list.table.lock | translate }}" ng-show="user.access_locked" class="fa fa-lock"></i>
              </div>
              <small>{{::user.email}}</small>
            </a>
            """,
            scope: { user: user }
          skip_natural: true}
          # User uid
          { header: locale["mnoe_admin_panel.dashboard.users.widget.list.table.uid"]
          style: {width: '130px'}
          attr:'uid'
          render: (user) ->
            template:
              "<span>{{::user.uid}}</span>"
            scope: {user: user}
          skip_natural: true}
          # User external_id
          { header: locale["mnoe_admin_panel.dashboard.users.widget.list.table.external_id"]
          style: {width: '130px'}
          attr:'external_id'
          render: (user) ->
            template:
              "<span>{{::user.external_id}}</span>"
            scope: {user: user}
          skip_natural: true}
          # User last_active_at
          { header: locale["mnoe_admin_panel.dashboard.users.widget.list.table.last_active_at"],
          style: {width: '130px'},
          attr:'last_active_at'
          render: (user) ->
            template: """
            <span data-toggle="tooltip" title="{{::user.last_active_at | date: 'H:m - dd/MM/yyyy'}}">
              {{(user.last_active_at | amTimeAgo) || ('mnoe_admin_panel.dashboard.users.widget.list.never' | translate)}}
            </span>
            """,
            scope: {user: user}
          skip_natural: true}
          # User last login date
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
          # User creation date
          { header: locale["mnoe_admin_panel.dashboard.users.widget.list.table.created_at"],
          style: {width: '130px'},
          attr:'created_at',
          sort_default: "reverse"
          render: (user) ->
            template:
              "<span>{{::user.created_at | date: 'dd/MM/yyyy'}}</span>"
            scope: {user: user}
          skip_natural: true}]
      )

    # Pipe for the sortable-table
    scope.pipe = (tableState) ->
      # MonkeyPatch to prevent pipes from reloading data till
      # first call is complete
      if !scope.firstLoadIsDone
        scope.firstLoadIsDone = true
        return

      # The order has changed - reset pagination
      scope.users.page = 1
      scope.users.sortAttr = tableState.sort.predicate
      if tableState.sort.reverse
        scope.users.sortAttr += ".desc"
      fetchUsers(scope.users.nbItems, 0, scope.users.sortAttr)

    # Fetch users
    fetchUsers = (limit, offset, sort = 'surname') ->
      scope.users.loading = true
      MnoeCurrentUser.getUser().then( ->
        params = scope.filterParams || {}
        return MnoeUsers.list(limit, offset, sort, params).then(
          (response) ->
            scope.users.totalItems = response.headers('x-total-count')
            scope.users.list = response.data
        ).finally(-> scope.users.loading = false)
      )

    displayCurrentState = () ->
      setAllUsersList()
      fetchUsers(scope.users.nbItems, 0, scope.users.sortAttr)

    # Display all the users
    setAllUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.list.all_users.title'
      scope.users.switchLinkTitle = 'mnoe_admin_panel.dashboard.users.widget.list.all_users.switch_link_title'

    scope.searchChange = () ->
      # After adding external_id in the search term update the minimum string length in the search from >= 3 to >=0
      if scope.users.search.length >= 0
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
      terms = {'surname.like': "#{search}%", 'name.like': "#{search}%", 'email.like': "%#{search}%", 'uid.like': "%#{search}%", 'external_id.like': "%#{search}%"}
      params = scope.filterParams || {}
      MnoeUsers.search(terms, params).then(
        (response) ->
          scope.users.totalItems = response.headers('x-total-count')
          scope.users.list = $filter('orderBy')(response.data, 'email')
      ).finally(-> scope.users.loading = false)

    # Initial call
    setAllUsersList()
)
