@App.controller 'UpdateAccountManagersController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeSubTenants, MnoeUsers, MnoErrorsHandler, MnoeAdminConfig, subTenant) ->
  'ngInject'
  vm = this
  # Variables initialization
  vm.changes = {add: [], remove: []}
  vm.staff_roles = MnoeAdminConfig.adminRoles()
  vm.getAdminRoleLabel = (admin_role) ->
    return _.find(vm.staff_roles, (role) -> role.value == admin_role).label

  # Manage sorting, search and pagination
  vm.callServer = (tableState) ->
    sort = updateSort(tableState.sort)
    search = updateSearch(tableState.search)
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
    search = {}
    if searchingState.predicateObject
      for attr, value of searchingState.predicateObject
        if attr == "admin_role"
          search[ 'where[admin_role]' ] = value
        else
          search[ 'where[' + attr + '.like]' ] = value + '%'

    # Update staff sort
    vm.staff.search = search
    return search

  vm.staff =
    search: {}
    sort: "surname"
    nbItems: 10
    page: 1
    pageChangedCb: (nbItems, page) ->
      vm.staff.nbItems = nbItems
      vm.staff.page = page
      offset = (page  - 1) * nbItems
      fetchStaffs(nbItems, offset)

  # Fetch staffs
  fetchStaffs = (limit, offset, sort = vm.staff.sort, search = vm.staff.search) ->
    vm.staff.loading = true
    return MnoeUsers.staffs(limit, offset, sort, search).then(
      (response) ->
        vm.staff.totalItems = response.headers('x-total-count')
        _.each(response.data, (u) -> u.belong_to_sub_tenant = (u.sub_tenant_id == subTenant.id))
        vm.listOfStaff = syncUsersWithChanges(response.data)
    ).finally(-> vm.staff.loading = false)

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeSubTenants.updateAccountManagers(subTenant, vm.changes).then(
      () ->
        $uibModalInstance.close()
        toastr.success("mnoe_admin_panel.dashboard.sub_tenant.select_account_managers.modal.toastr_success", {extraData: { sub_tenant_name: subTenant.name }})
      (error) ->
        toastr.error("mnoe_admin_panel.dashboard.sub_tenant.select_account_managers.modal.toastr_error", {extraData: { sub_tenant_name: subTenant.name }})
        $log.error("An error occurred while updating account managers of #{subTenant.name}.", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  vm.isDisabled = () ->
    vm.isLoading || (vm.changes.add.length == 0 && vm.changes.remove.length == 0)

  vm.checkBoxChanged = (user) ->
    if user.belong_to_sub_tenant
      index = _.indexOf(vm.changes.remove, user.id)
      if index == -1
        vm.changes.add.push(user.id)
      else
        vm.changes.remove.splice(index, 1)
    else
      index = _.indexOf(vm.changes.add, user.id)
      if index == -1
        vm.changes.remove.push(user.id)
      else
        vm.changes.add.splice(index, 1)

  syncUsersWithChanges = (users) ->
    _.map(users,
      (user) ->
        if _.contains(vm.changes.add, user.id)
          user.belong_to_sub_tenant = true
        else if _.contains(vm.changes.remove, user.id)
          user.belong_to_sub_tenant = false
        user
    )

  return
