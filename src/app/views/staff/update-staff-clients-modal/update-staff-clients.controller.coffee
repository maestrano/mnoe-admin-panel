@App.controller 'UpdateStaffClientsController', (staff, $filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, MnoeOrganizations) ->
  'ngInject'
  vm = this
  # Variables initialization
  vm.selectedOrganizations = {}
  for id in staff.client_ids
    vm.selectedOrganizations[id] = true

  vm.organizations =
    search: ''
    nbItems: 10
    page: 1
    pageChangedCb: (nbItems, page) ->
      vm.organizations.nbItems = nbItems
      vm.organizations.page = page
      offset = (page  - 1) * nbItems
      fetchOrganizations(nbItems, offset)

  # Fetch organisations
  fetchOrganizations = (limit, offset, sort = 'name') ->
    vm.organizations.loading = true
    params = {sub_tenant_id: staff.mnoe_sub_tenant_id}
    return MnoeOrganizations.list(limit, offset, sort, params).then(
      (response) ->
        vm.organizations.totalItems = response.headers('x-total-count')
        vm.organizations.list = response.data
    ).then(-> vm.organizations.loading = false)


  displayCurrentState = () ->
    setAllOrganizationsList()
    fetchOrganizations(vm.organizations.nbItems, 0)

  # Display all the organisations
  setAllOrganizationsList = () ->
    vm.organizations.widgetTitle = 'All organisations'

  vm.searchChange = () ->
# Only search if the string is >= than 3 characters
    if vm.organizations.search.length >= 3
      vm.searchMode = true
      setSearchOrganizationsList(vm.organizations.search)
# No search string, so display current state
    else if vm.searchMode
      vm.searchMode = false
      displayCurrentState()

  # Display only the search results
  setSearchOrganizationsList = (search) ->
    vm.organizations.loading = true
    vm.organizations.widgetTitle = 'Search result'
    search = vm.organizations.search.toLowerCase()
    terms = {'name.like': "%#{search}%"}
    MnoeOrganizations.search(terms).then(
      (response) ->
        vm.organizations.totalItems = response.headers('x-total-count')
        vm.organizations.list = $filter('orderBy')(response.data, 'name')
    ).finally(-> vm.organizations.loading = false)

  # Initial call
  displayCurrentState()


  vm.onSubmit = () ->
    vm.isLoading = true
    staff.client_ids = (orgId for orgId, val of vm.selectedOrganizations when val)
    MnoeUsers.updateStaff(staff).then(
      (result) ->
        toastr.success("#{staff.name} has been successfully updated.")
        $uibModalInstance.close(result.data.user.clients)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.staff.add_staff.modal.toastr_error', {extraData: { staff_name: staff.name }})
        $log.error("An error occurred while updating staff:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
