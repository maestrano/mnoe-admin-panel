@App.controller 'UpdateStaffClientsController', (staff, $filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, MnoeOrganizations) ->
  'ngInject'
  vm = this
  # Variables initialization
  vm.changes = {add: [], remove: []}

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
    params = {account_manager_id: staff.id}
    return MnoeOrganizations.list(limit, offset, sort, params).then(
      (response) ->
        vm.organizations.totalItems = response.headers('x-total-count')
        vm.organizations.list = syncOrganizationsWithChanges(response.data)
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
    params = {account_manager_id: staff.id}
    MnoeOrganizations.search(terms, params).then(
      (response) ->
        vm.organizations.totalItems = response.headers('x-total-count')
        vm.organizations.list = syncOrganizationsWithChanges($filter('orderBy')(response.data, 'name'))
    ).finally(-> vm.organizations.loading = false)

  # Initial call
  displayCurrentState()

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.updateStaffClients(staff, vm.changes).then(
      () ->
        $uibModalInstance.close()
        toastr.success("mnoe_admin_panel.dashboard.staff.update_staff.toastr_success", {extraData: { staff_name: "#{staff.name} #{staff.surname}"}})
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.staff.update_staff.modal.toastr_error', {extraData: { staff_name: "#{staff.name} #{staff.surname}" }})
        $log.error("An error occurred while updating staff:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  vm.isDisabled = () ->
    vm.isLoading || (vm.changes.add.length == 0 && vm.changes.remove.length == 0)

  vm.checkBoxChanged = (organization) ->
    if organization.belong_to_account_manager
      index = _.indexOf(vm.changes.remove, organization.id)
      if index == -1
        vm.changes.add.push(organization.id)
      else
        vm.changes.remove.splice(index, 1)
    else
      index = _.indexOf(vm.changes.add, organization.id)
      if index == -1
        vm.changes.remove.push(organization.id)
      else
        vm.changes.add.splice(index, 1)

  syncOrganizationsWithChanges = (organizations) ->
    _.map(organizations,
      (organization) ->
        if _.contains(vm.changes.add, organization.id)
          organization.belong_to_account_manager = true
        else if _.contains(vm.changes.remove, organization.id)
          organization.belong_to_account_manager = false
        organization
    )

  return
