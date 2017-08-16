#
# Mnoe Orders List
#
@App.component('mnoeOrdersList', {
  templateUrl: 'app/components/mnoe-orders-list/mnoe-orders-list.html',
  bindings: {
    view: '@',
  }
  controller: () ->
    vm = this

    vm.listOfOrders = []

    # Manage sorting, search and pagination
    vm.callServer = (tableState) ->

    vm.orders =
      editmode: []
      search: {}
      # sort: "surname"
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        vm.orders.nbItems = nbItems
        vm.orders.page = page
        offset = (page  - 1) * nbItems
        fetchOrders(nbItems, offset)

    # Fetch orders
    fetchOrders = (limit, offset, sort = vm.orders.sort, search = vm.orders.search) ->
      vm.orders.loading = true
      vm.listOfOrders = []

      vm.orders.loading = false

    fetchOrders(vm.orders.nbItems, 0)

    return

})
