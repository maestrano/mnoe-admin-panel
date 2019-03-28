#
# Mnoe Dashboard Templates list
#
@App.component('mnoeDashboardTemplatesList', {
  templateUrl: 'app/components/mnoe-dashboard-templates-list/mnoe-dashboard-templates-list.html',
  controller: (toastr, MnoConfirm, MnoeDashboardTemplates, MnoeAdminConfig) ->
    vm = this

    vm.datesFormat = MnoeAdminConfig.dashboardTemplatesDatesFormat()

    vm.dashboardTemplates =
      search: {}
      sort: "name"
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        vm.dashboardTemplates.nbItems = nbItems
        vm.dashboardTemplates.page = page
        offset = (page  - 1) * nbItems
        fetchDashboardTemplates(nbItems, offset)

    vm.callServer = (tableState) ->
      sort = updateSort(tableState.sort)
      search = updateSearch(tableState.search)
      fetchDashboardTemplates(vm.dashboardTemplates.nbItems, vm.dashboardTemplates.offset, sort, search)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "name"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update dashboardTemplates sort
      vm.dashboardTemplates.sort = sort

    # Update searching parameters
    updateSearch = (searchingState = {}) ->
      search = {}
      if searchingState.predicateObject
        for attr, value of searchingState.predicateObject
          search[ 'where[' + attr + '.like]' ] = value + '%'

      # Update dashboardTemplates sort
      vm.dashboardTemplates.search = search

    #====================================
    # Dashboard Template deletion Modal
    #====================================
    vm.openDeleteModal = (dashboardTemplateId) ->
      modalOptions =
        type: 'danger'
        closeButtonText: 'mnoe_admin_panel.dashboard.dashboard_templates.modal.cancel'
        actionButtonText: 'mnoe_admin_panel.dashboard.dashboard_templates.modal.delete'
        headerText: 'mnoe_admin_panel.dashboard.dashboard_templates.modal.delete_dashboard'
        bodyText: 'mnoe_admin_panel.dashboard.dashboard_templates.modal.are_you_sure'

      MnoConfirm.showModal(modalOptions).then(
        ->
          MnoeDashboardTemplates.delete(dashboardTemplateId).then(
            (success) ->
              toastr.success('mnoe_admin_panel.dashboard.dashboard_templates.widget.list.toastr.deleted.successfully')
              # Reload the list after deletion
              fetchDashboardTemplates()
            (error) ->
              toastr.error('mnoe_admin_panel.dashboard.dashboard_templates.widget.list.toastr.deleted.error')
          )
        ->
          # Cancelled
      )

    #====================================
    # Retrieve Dashboard Templates
    #====================================
    fetchDashboardTemplates = (limit, offset, sort = vm.dashboardTemplates.sort, search = vm.dashboardTemplates.search) ->
      vm.dashboardTemplates.loading = true
      return MnoeDashboardTemplates.templates(limit, offset, sort, search).then(
        (response) ->
          vm.dashboardTemplates.totalItems = response.headers('x-total-count')
          vm.dashboardTemplates.list = response.data
      ).finally(-> vm.dashboardTemplates.loading = false)


    vm.toggleTemplatePublished = (id) ->
      MnoeDashboardTemplates.toggleTemplatePublished(id)

    return
})
