#
# Mnoe Dashboard Templates list
#
@App.component('mnoeDashboardsList', {
  templateUrl: 'app/components/mnoe-dashboards/mnoe-dashboards.html',
  bindings: {
    userId: '<'
  },
  controller: ($uibModal, toastr, MnoeDashboardTemplates, MnoeAdminConfig) ->
    vm = this

    vm.dashboards =
      search: {}
      sort: "created_at"
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        vm.dashboards.nbItems = nbItems
        vm.dashboards.page = page
        offset = (page  - 1) * nbItems
        fetchDashboards(nbItems, offset)

    vm.callServer = (tableState) ->
      sort = updateSort(tableState.sort)
      search = updateSearch(tableState.search)
      fetchDashboards(vm.dashboards.nbItems, vm.dashboards.offset, sort, search)

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

    # Update searching parameters
    updateSearch = (searchingState = {}) ->
      search = {}
      if searchingState.predicateObject
        for attr, value of searchingState.predicateObject
          search[ 'where[' + attr + '.like]' ] = value + '%'

      # Update dashboards sort
      vm.dashboards.search = search

    #====================================
    # Retrieve Dashboard Templates
    #====================================
    fetchDashboards = (limit, offset, sort = vm.dashboards.sort, search = vm.dashboards.search) ->
      vm.dashboards.loading = true
      return MnoeUsers.getUsersDashboards(this.userId, limit, offset, sort, search).then(
        (response) ->
          vm.dashboards.totalItems = response.headers('x-total-count')
          vm.dashboards.list = response.data
      ).finally(-> vm.dashboards.loading = false)


    vm.toggleTemplatePublished = (id) ->
      MnoeDashboardTemplates.toggleTemplatePublished(id)

    return
})
