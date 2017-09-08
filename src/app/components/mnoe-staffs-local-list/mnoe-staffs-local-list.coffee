@App.directive('mnoeStaffsLocalList', (ADMIN_ROLES) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-staffs-local-list/mnoe-staffs-local-list.html',
  link: (scope, _elem, _attrs) ->
    scope.getAdminRoleLabel = (staff) ->
      return _.find(ADMIN_ROLES, (role) -> role.value == staff.admin_role).label

)
