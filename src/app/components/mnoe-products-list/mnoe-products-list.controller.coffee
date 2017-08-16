#
# Mnoe Products List
#
@App.component('mnoeProductsList', {
  templateUrl: 'app/components/mnoe-products-list/mnoe-products-list.html',
  bindings: {}
  controller: ($state, $uibModal, MnoeProducts) ->
    vm = this

    vm.products =
      search: {}
      sort: "name"
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        vm.products.nbItems = nbItems
        vm.products.page = page
        offset = (page  - 1) * nbItems
        fetchProducts(nbItems, offset)

    vm.callServer = (tableState) ->
      sort = updateSort (tableState.sort)
      search = updateSearch (tableState.search)
      fetchProducts(vm.products.nbItems, vm.products.offset, sort, search)

    # Update sorting parameters
    updateSort = (sortState = {}) ->
      sort = "name"
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"

      # Update products sort
      vm.products.sort = sort
      return sort

    updateSearch = (searchingState = {}) ->
      search = {}
      if searchingState.predicateObject
        value = searchingState.predicateObject.name
        search[ 'where[name.like]' ] = value + '%'

        # Update product sort
      vm.products.search = search
      return search

    vm.delete = (product) ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/products/modals/delete-product-modal.html'
        controller: 'DeleteProductController'
        controllerAs: 'vm'
        resolve:
          product: product
      )
      modalInstance.result.then(
        (result) ->
          # If the user decide to remove the product
          if result
            fetchProducts(vm.products.nbItems, 0)
      )

    # Fetch products
    fetchProducts = (limit, offset, sort = vm.products.sort, search = vm.products.search) ->
      vm.products.loading = true

      return MnoeProducts.products(limit, offset, sort, search).then(
        (response) ->
          vm.products.totalItems = response.headers('x-total-count')
          vm.listOfProducts = response.data
      ).then( -> vm.products.loading = false )

    return
})
