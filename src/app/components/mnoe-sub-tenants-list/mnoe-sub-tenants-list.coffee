#
# Mnoe organizations List
#
@App.component('mnoeSubTenantsList', {
  templateUrl: 'app/components/mnoe-sub-tenants-list/mnoe-sub-tenants-list.html',
  bindings: {
    view: '@',
  }
  controller: ($filter, $log, toastr, MnoeSubTenants, MnoConfirm, MnoeObservables, OBS_KEYS) ->
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
            toastr.success('mnoe_admin_panel.dashboard.sub_tenants.update_sub_tenant.toastr_success', {extraData: {sub_tenant_name: subTenant.name}})
            # Remove the edit mode for this user
            delete vm.subTenant.editmode[subTenant.id]
          (error) ->
            $log.error('Error while updating subTenant', error)
            toastr.error('mnoe_admin_panel.dashboard.sub_tenants.update_sub_tenant.toastr_error')
        )

      remove: (subTenant) ->
        modalOptions =
          closeButtonText: 'mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.cancel'
          actionButtonText: 'mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.delete'
          headerText: 'mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.proceed'
          headerTextExtraData: {sub_tenant_name: subTenant.name}
          bodyText: 'mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.perform'

        MnoConfirm.showModal(modalOptions).then(->
          MnoeSubTenants.delete(subTenant.id).then(->
            toastr.success('mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.toastr_success', {extraData: {sub_tenant_name: subTenant.name}})
          )
          (error) ->
            $log.error('Error while deleting subTenant', error)
            toastr.error('mnoe_admin_panel.dashboard.sub_tenants.remove_sub_tenant.toastr_success')
        )

    # Fetch subTenants
    fetchSubTenants = (limit, offset, sort = vm.subTenant.sort) ->
      vm.subTenant.loading = true
      return MnoeSubTenants.list(limit, offset, sort).then(
        (response) ->
          vm.subTenant.totalItems = response.headers('x-total-count')
          vm.listOfSubTenant = response.data
      ).finally(-> vm.subTenant.loading = false)

    # Notify me if a subTenant is added
    MnoeObservables.registerCb(OBS_KEYS.subTenantAdded, ->
      fetchSubTenants(vm.subTenant.nbItems, vm.subTenant.offset)
    )

    # Notify me if the list changes
    MnoeObservables.registerCb(OBS_KEYS.subTenantChanged, ->
      fetchSubTenants(vm.subTenant.nbItems, vm.subTenant.offset)
    )

    return
})
