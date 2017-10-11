#
# Mnoe organizations List
#
@App.component('mnoeStaffsList', {
  templateUrl: 'app/components/mnoe-staffs-list/mnoe-staffs-list.html',
  bindings: {
    view: '@',
    filterParams: '='
  }
  controller: ($filter, $log, MnoeAdminConfig, MnoeUsers, MnoeCurrentUser, MnoConfirm, MnoeObservables, OBS_KEYS, toastr) ->
    vm = this

    vm.listOfStaff = []

    # Manage sorting, search and pagination
    vm.callServer = (tableState) ->
      sort   = updateSort (tableState.sort)
      search = updateSearch (tableState.search)
      fetchStaffs(vm.staff.nbItems, vm.staff.offset, sort, search)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "surname"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update staff sort
      vm.staff.sort = sort
      return sort

    # Update searching parameters
    updateSearch = (searchingState = {}) ->
      search = vm.filterParams || {}
      if searchingState.predicateObject
        for attr, value of searchingState.predicateObject
          if attr == "admin_role"
            search[ 'where[admin_role.in]' ] = value
          else
            search[ 'where[' + attr + '.like]' ] = value + '%'

      # Update staff sort
      vm.staff.search = search
      return search

    vm.getAdminRoleLabel = (admin_role) ->
      return _.find(vm.staff.roles, (role) -> role.value == admin_role).label

    vm.staff =
      editmode: []
      search: {}
      sort: "surname"
      nbItems: 10
      page: 1
      roles: MnoeAdminConfig.adminRoles()
      pageChangedCb: (nbItems, page) ->
        vm.staff.nbItems = nbItems
        vm.staff.page = page
        offset = (page  - 1) * nbItems
        fetchStaffs(nbItems, offset)

      update: (staff) ->
        MnoeUsers.updateStaff(staff).then(
          (response) ->
            updateSort()
            updateSearch()
            # Remove the edit mode for this user
            delete vm.staff.editmode[staff.id]
            MnoeCurrentUser.refreshUser()
          (error) ->
            $log.error('Error while saving user', error)
            toastr.error('mnoe_admin_panel.dashboard.staffs.widget.list.toastr_error')
        )

      remove: (staff) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.staffs.modal.remove_staff.cancel'
          actionButtonText: 'mnoe_admin_panel.dashboard.staffs.modal.remove_staff.delete'
          headerText: 'mnoe_admin_panel.dashboard.staffs.modal.remove_staff.proceed'
          headerTextExtraData: { staff_name: "#{staff.name} #{staff.surname}"}
          bodyText: 'mnoe_admin_panel.dashboard.staffs.modal.remove_staff.perform'

        MnoConfirm.showModal(modalOptions).then( ->
          MnoeUsers.removeStaff(staff.id).then( ->
            toastr.success('mnoe_admin_panel.dashboard.staffs.widget.list.toastr_success', {extraData: {staff_name: "#{staff.name} #{staff.surname}"}})
          )
          (error) ->
            $log.error('Error while removing user', error)
            toastr.error('mnoe_admin_panel.dashboard.staff.modal.remove_staff.toastr_error')
        )

    # Fetch staffs
    fetchStaffs = (limit, offset, sort = vm.staff.sort, search = vm.staff.search) ->
      vm.staff.loading = true
      if MnoeCurrentUser.user.admin_role == 'sub_tenant_admin'
        search[ 'where[mnoe_sub_tenant_id]' ] = MnoeCurrentUser.user.mnoe_sub_tenant_id
      return MnoeUsers.staffs(limit, offset, sort, search).then(
        (response) ->
          vm.staff.totalItems = response.headers('x-total-count')
          vm.listOfStaff = response.data
          vm.staff.oneAdminLeft = _.filter(response.data, {'admin_role': 'admin'}).length == 1
      ).finally(-> vm.staff.loading = false)

    onStaffAdded = ->
      fetchStaffs(vm.staff.nbItems, vm.staff.offset)

    onStaffChanged = ->
      fetchStaffs(vm.staff.nbItems, vm.staff.offset)

    # Notify me if a user is added
    MnoeObservables.registerCb(OBS_KEYS.staffAdded, onStaffAdded)
    # Notify me if the list changes
    MnoeObservables.registerCb(OBS_KEYS.staffChanged, onStaffChanged)

    this.$onDestroy = ->
      MnoeObservables.unsubscribe(OBS_KEYS.staffAdded, onStaffAdded)
      MnoeObservables.unsubscribe(OBS_KEYS.staffChanged, onStaffChanged)

    return
})
