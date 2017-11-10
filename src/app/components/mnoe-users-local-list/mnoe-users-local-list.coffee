#
# Mnoe Users List
#
@App.directive('mnoeUsersLocalList', ($filter, $log, toastr, MnoeAdminConfig, MnoeUsers, MnoErrorsHandler, $translate, MnoConfirm) ->
  restrict: 'E'
  scope: {
    list: '='
    organization: '='
  },
  templateUrl: 'app/components/mnoe-users-local-list/mnoe-users-local-list.html',
  link: (scope, elem, attrs) ->
    scope.isImpersonationEnabled = MnoeAdminConfig.isImpersonationEnabled()
    # Variables initialization
    scope.users =
      displayList: []
      widgetTitle: 'mnoe_admin_panel.dashboard.users.widget.local_list.loading_users.title'
      search: ''

    # Display all the users
    setAllUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.local_list.all_users.title'
      scope.users.switchLinkTitle = 'mnoe_admin_panel.dashboard.users.widget.local_list.all_users.switch_link_title'
      scope.users.displayList = $filter('orderBy')(scope.list, 'email')

    # Display only the last 10 users
    setLastUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.local_list.last_users.title'
      scope.users.switchLinkTitle = 'mnoe_admin_panel.dashboard.users.widget.local_list.last_users.switch_link_title'
      scope.users.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.users.displayList = $filter('limitTo')(scope.users.displayList, 10)

    # Display only the search results
    setSearchUsersList = () ->
      scope.users.widgetTitle = 'mnoe_admin_panel.dashboard.users.widget.local_list.search_users.title'
      delete scope.users.switchLinkTitle
      searchToLowerCase = scope.users.search.toLowerCase()
      scope.users.displayList = _.filter(scope.list, (user) ->
        email = _.contains(user.email.toLowerCase(), searchToLowerCase) if user.email
        name = _.contains(user.name.toLowerCase(), searchToLowerCase) if user.name
        surname = _.contains(user.surname.toLowerCase(), searchToLowerCase) if user.surname
        (email || name || surname)
      )
      scope.users.displayList = $filter('orderBy')(scope.users.displayList, 'email')

    displayNormalState = () ->
      # if view="all" is set on the directive, all the users are displayed
      # if view="last" is set on the directive, the last 10 users are displayed
      if attrs.view == 'all'
        setAllUsersList()
      else if attrs.view == 'last'
        setLastUsersList()
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    scope.switchState = () ->
      if attrs.view == 'all'
        attrs.view = 'last'
      else
        attrs.view = 'all'
      displayNormalState()

    scope.searchChange = () ->
      if scope.users.search == ''
        displayNormalState()
      else
        setSearchUsersList()

    # Send an invitation to a user
    scope.sendInvitation = (user) ->
      user.isSendingInvite = true
      MnoeUsers.inviteUser(scope.organization, user).then(
        (response) ->
          toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.toastr_success', {extraData: {username: "#{user.name} #{user.surname}"}})
          # Update status
          user.status = response.data.user.status
        (error) ->
          toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.toastr_error', {extraData: {username: "#{user.name} #{user.surname}"}})
          MnoErrorsHandler.processServerError(error)
      ).finally(-> user.isSendingInvite = false)

    scope.availableRoles = () ->
      [
        "mnoe_admin_panel.constants.user_roles.member",
        "mnoe_admin_panel.constants.user_roles.admin",
        "mnoe_admin_panel.constants.user_roles.super_admin"
      ]

    scope.indexOfRoleInTable = (role) ->
      scope.availableRoles().indexOf(scope.tlKeyFromUserRole(role))

    # role here should always be in English (as returned by MnoHub)
    scope.tlKeyFromUserRole = (role) ->
      enTranslationTable = $translate.getTranslationTable('en-AU')
      _.findKey(enTranslationTable, _.partial(_.isEqual, role))

    scope.updateUserMail = (user) ->
      user.isUpdatingEmail = true
      MnoeUsers.updateStaff(user).then(
        (response) ->
          toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.email_update_sent', {extraData: {email: user.email}})
        (error) ->
          toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.email_update_error')
          MnoErrorsHandler.processServerError(error)
      ).finally(-> user.isUpdatingEmail = false)

    scope.updateUserRole = (user) ->
      user.isUpdatingRole = true
      # We need to send to MnoHub the role value in English
      $translate(user.role).then((tls) ->
        user.role = tls
        MnoeUsers.updateMember(scope.organization, user).then(
          (response) ->
            toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.role_update_success', {extraData: {user: "#{user.name} #{user.surname}", role: user.role}})
            user.role = scope.tlKeyFromUserRole(user.role)
          (error) ->
            toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.role_update_error')
            MnoErrorsHandler.processServerError(error)
        ).finally(-> user.isUpdatingRole = false)
      )

    scope.removeMember = (member) ->
      modalOptions =
        closeButtonText: 'mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.cancel'
        actionButtonText: 'mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.delete'
        headerText: 'mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.proceed'
        bodyText: 'mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.perform'
        bodyTextExtraData: {email: member.email}
        type: 'danger'

      MnoConfirm.showModal(modalOptions).then( ->
        MnoeUsers.deleteMember(scope.organization, member).then(
          (response) ->
            _.remove(scope.users.displayList, member)
            toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.success', {extraData: {email: member.email}})
          (error) ->
            toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.remove_member.error', {extraData: {email: member.email}})
            MnoErrorsHandler.processServerError(error)
        )
      )

    scope.$watch('list', (newVal) ->
      if newVal
        displayNormalState()
    , true)
)
