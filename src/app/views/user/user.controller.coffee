@App.controller 'UserController', ($stateParams, MnoeUsers, UserRoles, $translate, toastr, MnoErrorsHandler, MnoeOrganizations) ->
  'ngInject'
  vm = this
  vm.user = {}
  vm.orgTableCustomizations = {}
  # Get the user
  MnoeUsers.get($stateParams.userId).then(
    (response) ->
      vm.user = response.data
      countryCode = vm.user.phone_country_code
      phone = vm.user.phone
      if phone && countryCode
        vm.user.phone = '+' + countryCode + phone

      vm.orgTableCustomizations.searchParams = { 'where[users.id]': vm.user.id }

      # These bindings are so that we can add additional fields with functionality to the organization table.
      vm.orgTableCustomizations.bindings = {
        userRoles: UserRoles
        user: vm.user

        editRole: (organization) ->
          # Keep track of old roles when editing organization's roles.
          organization.beforeEditRole = organization.role
          organization.editMode = true

        exitEditRole: (organization) ->
          organization.role = organization.beforeEditRole
          organization.editMode = false

        updateUserRole: (organization, user) ->
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
            ).finally(() ->
              # So that the organization/user reverts back to non-editing view.
              organization.beforeEditRole = null
              organization.isUpdatingRole = false
              organization.editMode = false
            )
        }
  )

  $translate('mnoe_admin_panel.dashboard.organization.widget.local_list.search_organizations.table.role')
    .then((translation) ->
      vm.orgTableCustomizations.fields = [
        {
          header: translation
          style: {
            width: '130px'
          }
          skip_natural: false
          render: (organization, bindings) ->
            template: "
              <select ng-show='organization.editMode' ng-model='organization.role' ng-options='role.value as role.translatedLabel for role in userRoles.availableRolesForOptions'></select>
              <span ng-show='organization.isUpdatingRole'><i class='fa fa-spinner fa-pulse fa-fw'></i></span>
              <span ng-click='editRole(organization)' ng-hide='organization.editMode'>{{ userRoles.keyFromRole(organization.role) | translate }}</span>
              <a class='role_edit_link' ng-hide='organization.editMode' ng-click='editRole(organization)'><i class='fa fa-pencil'></i></a>
              <a class='role_edit_link' ng-show='organization.editMode' ng-click='updateUserRole(organization, user)'><i class='fa fa-check'></i></a>
              <a class='role_edit_link' ng-show='organization.editMode' ng-click='exitEditRole(organization)'><i class='fa fa-times'></i></a>
              <span ng-show='vm.isSaving'><i class='fa fa-spinner fa-pulse fa-fw'></i></span>
            "
            scope: {
              organization: organization
              user: bindings.user,
              editRole: bindings.editRole
              updateUserRole: bindings.updateUserRole
              exitEditRole: bindings.exitEditRole
              userRoles: bindings.userRoles
            }
        }
      ]
    )

  vm.orgTableCustomizations.getOrganizations = (limit, offset, sort = 'created_at') ->
    return unless vm.user['id']
    params = vm.orgTableCustomizations.searchParams
    MnoeOrganizations.list(limit, offset, sort, params)

  return
