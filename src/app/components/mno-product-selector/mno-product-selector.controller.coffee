###
#   @desc Modal used to select one or multiple products
#   @binding {Array} [resolve.products] The list of products to be displayed
#   @binding {Boolean} [resolve.multiple] Is the user allowed to select more than one product?
###
@App.component('mnoProductSelectorModal', {
  bindings: {
    resolve: '<'
    close: '&'
    dismiss: '&'
  },
  templateUrl: 'app/components/mno-product-selector/mno-product-selector.html',
  controller: ($window, $q, orderByFilter, MnoeProducts, MnoeMarketplace, MnoeApps, MnoeProvisioning) ->
    'ngInject'

    $ctrl = this

    selectedProductsPromise = ->
      deferred = $q.defer()

      switch $ctrl.flag
        when 'organization-create-order'
          MnoeProducts.get($ctrl.selectedProducts[0].id).then(
            (response) ->
              deferred.resolve response.data
          )
        when 'settings-add-new-app'
          $ctrl.selectedProducts = if $ctrl.purchasableType == 'user_purchasable' then $ctrl.selectedProducts else $ctrl.selectedProducts[0]
          deferred.resolve $ctrl.selectedProducts
      deferred.promise

    $ctrl.$onInit = ->
      $ctrl.flag = $ctrl.resolve.dataFlag
      $ctrl.isTenantPurchasableFlag = $ctrl.resolve.isTenantPurchasable || false
      $ctrl.purchasableType = $ctrl.resolve.purchasableType || 'user_purchasable'
      $ctrl.resolveProducts()
      $ctrl.multiple = $ctrl.resolve.multiple
      $ctrl.modalHeight = ($window.innerHeight - 200) + "px"
      $ctrl.selectedProducts = []
      $ctrl.selectedCategory = ''
      $ctrl.searchTerm = ''
      $ctrl.headerText = $ctrl.resolve.headerText || 'mnoe_admin_panel.components.mno-product-selector.title'
      $ctrl.actionButtonText = $ctrl.resolve.actionButtonText || 'mnoe_admin_panel.components.mno-product-selector.create_order'

    $ctrl.resolveProducts = ->
      $ctrl.isLoadingProducts = true

      params = {
        skip_dependencies: true,
        includes: ['categories']
        fields: {
          products: ['name, logo, categories']
          categories: ['name']
        },
        'where[active]': true
      }
      $ctrl.isLoadingProducts = true

      promise =
        switch $ctrl.flag
          when 'organization-create-order'
            MnoeProducts.products(_, _, _, params)
          when 'settings-add-new-app'
            params = { 'where[purchasables]': $ctrl.purchasableType }
            MnoeApps.list(params).then(
              (response) ->
                debuggerx
                apps = $ctrl.resolve.enabledApps
                # Copy the response, we're are modifying the response in place and
                # don't want to modify the cached version in MnoeApps
                resp = angular.copy(response)
                enabledIds = _.map(apps, 'id')
                # TODO: We need to remove this check once we create the query structure for subscription based products
                _.remove(resp.data, (app)-> _.includes(enabledIds, app.id)) unless $ctrl.purchasableType == 'tenant_purchasable'
                resp
            )

      promise.then(
        (response) ->
          # Extract the categories
          categories = (product.categories for product in response.data)
          $ctrl.categories = _.uniq([].concat categories...)

          $ctrl.products = orderByFilter(response.data, 'name')
          $ctrl.filteredProducts = $ctrl.products
      ).finally(-> $ctrl.isLoadingProducts = false)

    # Filter products by name or category
    $ctrl.onSearchChange = () ->
      $ctrl.selectedCategory = ''
      term = $ctrl.searchTerm.toLowerCase()
      $ctrl.filteredProducts = (product for product in $ctrl.products when product.name.toLowerCase().indexOf(term) isnt -1)

    $ctrl.onCategoryChange = () ->
      $ctrl.searchTerm = ''
      if ($ctrl.selectedCategory?.length > 0)
        $ctrl.filteredProducts = (product for product in $ctrl.products when $ctrl.selectedCategory in product.categories)
      else
        $ctrl.filteredProducts = $ctrl.products

    # Select or deselect a product
    $ctrl.toggleProduct = (product) ->
      if product.checked
        _.remove($ctrl.selectedProducts, product)
      else
        return if (!$ctrl.multiple && $ctrl.selectedProducts.length > 0)
        $ctrl.selectedProducts.push(product)
      product.checked = !product.checked

    # Close the modal and return the selected products
    $ctrl.closeModal = ->
      $ctrl.isLoadingProducts = true
      MnoeProvisioning.setSubscription({})

      promise = selectedProductsPromise()
      promise.then(
        (response) ->
          $ctrl.close({$value: response})
      ).finally(-> $ctrl.isLoadingProducts = false)

    $ctrl.dismissModal = ->
      $ctrl.dismiss()

    return
})
