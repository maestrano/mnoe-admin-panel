@App.controller 'UpdateAccountManagersController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeSubTenants, MnoeUsers, MnoErrorsHandler, ADMIN_ROLES, subTenant) ->
  'ngInject'
  vm = this
  # Variables initialization
  vm.selectedUsers = {}
  _.each(subTenant.account_manager_ids, (id) -> vm.selectedUsers[id] = true)
  vm = this
  vm.staff_roles = ADMIN_ROLES
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
          search[ 'where[admin_role.in][]' ] = [value]
        else
          search[ 'where[' + attr + '.like]' ] = value + '%'

    # Update staff sort
    vm.staff.search = search
    return search

  # Widget state
  vm.state = vm.view

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
        vm.listOfStaff = response.data
    ).finally(-> vm.staff.loading = false)

  vm.onSubmit = () ->
    vm.isLoading = true
    subTenant.account_manager_ids = (orgId for orgId, val of vm.selectedUsers when val)
    MnoeSubTenants.update(subTenant).then(
      (result) ->
        toastr.success("mnoe_admin_panel.dashboard.sub_tenant.select_account_managers.modal.toastr_success", {extraData: { sub_tenant_name: subTenant.name }})
        $uibModalInstance.close(result.data.sub_tenant.account_managers)
      (error) ->
        toastr.error("mnoe_admin_panel.dashboard.sub_tenant.select_account_managers.modal.toastr_error", {extraData: { sub_tenant_name: subTenant.name }})
        $log.error("An error occurred while updating account managers of #{subTenant.name}.", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
