#
# Mnoe dashboards list.
#
@App.component('mnoeDashboardsList', {
  templateUrl: 'app/components/mnoe-dashboards-list/mnoe-dashboards-list.html',
  controller: (MnoeUsers, $stateParams) ->
    vm = this

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
    # Retrieve Dashboard Templates
    #====================================
    fetchDashboards = (limit, offset, sort = vm.dashboards.sort) ->
      vm.dashboards.loading = true
      return MnoeUsers.getUsersDashboards($stateParams.userId, limit, offset, sort).then(
        (response) ->
          vm.dashboards.totalItems = response.headers('x-total-count')
          vm.dashboards.list = response.data
      ).finally(-> vm.dashboards.loading = false)

    vm.toggleTemplatePublished = (id) ->
      MnoeDashboardTemplates.toggleTemplatePublished(id)

    vm.currency = (entity) ->
      entity.settings?.currency

    vm.toggleDashboard = (dashboard) ->
      if dashboard.opened
        dashboard.opened = false
        dashboard.widgetOpened = false
        dashboard.kpiOpened = false
      else
        dashboard.opened = true

    vm.toggleDashboardWidgets = (dashboard) ->
      dashboard.widgetOpened = !dashboard.widgetOpened

    vm.toggleDashboardKpis = (dashboard) ->
      dashboard.kpiOpened = !dashboard.kpiOpened

    return
})
