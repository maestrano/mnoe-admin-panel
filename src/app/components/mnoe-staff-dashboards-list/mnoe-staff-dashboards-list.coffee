#
# Mnoe staff dashboards list.
#
@App.component('mnoeStaffDashboardsList', {
  templateUrl: 'app/components/mnoe-staff-dashboards-list/mnoe-staff-dashboards-list.html'
  bindings: {
    organization: '<'
  }

  controller: (toastr, MnoConfirm, MnoeDashboards, ImpacDashboardsSvc, ImpacConfigSvc) ->
    vm = this

    vm.$onChanges = (changes) ->
      if changes.organization && vm.organization
        fetchDashboards()

    vm.dashboards =
      sort: "created_at"
      nbItems: 5
      page: 1
      offset: 0
      nbItemsValues: [5, 10, 20]
      pageChangedCb: (nbItems, page) ->
        vm.dashboards.nbItems = nbItems
        vm.dashboards.page = page
        offset = (page  - 1) * nbItems
        fetchDashboards(nbItems, offset)

    vm.callServer = (tableState) ->
      sort = updateSort(tableState.sort)
      fetchDashboards(vm.dashboards.nbItems, vm.dashboards.offset, sort)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "name"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update dashboards sort
      vm.dashboards.sort = sort

    #====================================
    # Reconfigure Impac!
    #====================================
    ImpacConfigSvc.disableDashboardDesigner()

    #====================================
    # Retrieve Staff Dashboard
    #====================================
    fetchDashboards = (limit = vm.dashboards.nbItems, offset = vm.dashboards.offset, sort = vm.dashboards.sort) ->
      vm.dashboards.loading = true
      return unless vm.organization
      return MnoeDashboards.getStaffDashboards(vm.organization.uid, limit, offset, sort).then(
        (response) ->
          vm.dashboards.totalItems = response.headers('x-total-count')
          vm.dashboards.list = response.data
      ).finally(-> vm.dashboards.loading = false)

    #====================================
    # Staff dashboard deletion Modal
    #====================================
    vm.openDeleteModal = (dashboardId) ->

      modalOptions =
        type: 'danger'
        closeButtonText: 'mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.cancel'
        actionButtonText: 'mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.action'
        headerText: 'mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.proceed'
        bodyText: 'mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.perform'
      MnoConfirm.showModal(modalOptions).then(
        ->
          MnoeDashboards.delete(dashboardId).then(
            (success) ->
              toastr.success('mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.toastr.success')
              # Reload list if the user deleted a dashboard
              fetchDashboards()
            (error) ->
              toastr.error('mnoe_admin_panel.dashboard.staff_dashboards.delete_dashboard.toastr.error')
          )
        ->
          # Cancel
      )

    # -----------------------------------------------------------
    # Advisor Dashboard
    # -----------------------------------------------------------
    vm.createDashboard = (dashboard) ->
      # TODO: bug when creating after copying (also present on frontend)
      promise = if dashboard.id
        ImpacDashboardsSvc.copy(dashboard)
      else
        ImpacDashboardsSvc.create(dashboard)

      # TODO: toaster
      # refresh dashboard list OR redirect to created dashboard
      promise.then(
        (savedDhb) ->
          fetchDashboards()
          # $state.go('dashboard.staff-dashboard-show', dashboardId: dashboard.id, orgId: vm.organization.id)
      )

    return
})
