#
# Mnoe organizations List
#
@App.component('mnoeSubTenantsList', {
  templateUrl: 'app/components/mnoe-sub-tenants-list/mnoe-sub-tenants-list.html',
  bindings: {
    view: '@',
  }
  controller: ($filter, $log, toastr, MnoeSubTenants, MnoConfirm, MnoeObservables, OBS_KEYS,) ->
    vm = this

    vm.listOfSubTenant = []

    # Manage sorting, search and pagination
    vm.callServer = (tableState) ->
      sort = updateSort (tableState.sort)
      fetchSubTenants(vm.subTenant.nbItems, vm.subTenant.offset, sort)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "name"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update subTenant sort
      vm.subTenant.sort = sort
      return sort

    # Widget state
    vm.state = vm.view

    vm.subTenant =
      editmode: []
      search: {}
      sort: "name"
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        vm.subTenant.nbItems = nbItems
        vm.subTenant.page = page
        offset = (page - 1) * nbItems
        fetchSubTenants(nbItems, offset)

      update: (subTenant) ->
        MnoeSubTenants.update(subTenant).then(
          () ->
            toastr.success("#{subTenant.name} has been successfully updated.")
            # Remove the edit mode for this user
            delete vm.subTenant.editmode[subTenant.id]
          (error) ->
            # Display an error
            $log.error('Error while saving sub tenant', error)
            toastr.error('An error occurred while saving the Division.')
        )

      remove: (subTenant) ->
        modalOptions =
          closeButtonText: 'Cancel'
          actionButtonText: 'Delete Division'
          headerText: 'Delete ' + subTenant.name + '?'
          bodyText: 'Are you sure you want to delete this Division'

        MnoConfirm.showModal(modalOptions).then(->
          console.log 'Remove subTenant:' + subTenant.id
          MnoeSubTenants.delete(subTenant.id).then(->
            toastr.success("#{subTenant.name} has been successfully removed.")
          )
        )

    # Fetch subTenants
    fetchSubTenants = (limit, offset, sort = vm.subTenant.sort) ->
      vm.subTenant.loading = true
      return MnoeSubTenants.list(limit, offset, sort).then(
        (response) ->
          vm.subTenant.totalItems = response.headers('x-total-count')
          vm.listOfSubTenant = response.data
      ).finally(-> vm.subTenant.loading = false)

    MnoeObservables.registerCb(OBS_KEYS.subTenantAdded, ->
      fetchSubTenants(vm.subTenant.nbItems, vm.subTenant.offset)
    )
    # Notify me if the list changes
    MnoeObservables.registerCb(OBS_KEYS.subTenantChanged, ->
      fetchSubTenants(vm.subTenant.nbItems, vm.subTenant.offset)
    )

    return

})
