@App.directive('mnoeStaffsLocalList', (MnoeAdminConfig) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-staffs-local-list/mnoe-staffs-local-list.html',
  link: (scope, _elem, _attrs) ->
    scope.getAdminRoleLabel = (staff) ->
      return _.find(MnoeAdminConfig.adminRoles(), (role) -> role.value == staff.admin_role).label

)
