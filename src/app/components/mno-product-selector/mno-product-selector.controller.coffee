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
  controller: ($window, $q, $translate, orderByFilter, MnoeProducts, MnoeApps, MnoeProvisioning) ->
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
          deferred.resolve $ctrl.selectedProducts
      deferred.promise

    $ctrl.$onInit = ->
      $ctrl.flag = $ctrl.resolve.dataFlag
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
        includes: ['categories', 'values']
        fields: {
          products: ['name, nid, logo, categories, values, multi_instantiable']
          categories: ['name']
          values: ['field', 'data']
        },
        'where[active]': true
      }
      $ctrl.isLoadingProducts = true

      promise =
        switch $ctrl.flag
          when 'organization-create-order'
            MnoeProducts.products(_, _, _, params).then(
              (response) ->
                # Pull nids from organization active app instances
                activeNids = (product.nid for product in $ctrl.resolve.activeInstances)
                # Add attributes to all products that are not orderable.
                # These attributes will be used to disable selection of these products.
                _.each(response.data, (product) ->
                  # Check for products that cannot be ordered due to not being
                  # multi_intantiable.
                  if !product.multi_instantiable and (product.nid in activeNids)
                    product.orderDisabled = true
                    product.disabledToolTip = $translate.instant('mnoe_admin_panel.components.mno-product-selector.tooltip.multi_instantiable')
                )
                response
            )

          when 'settings-add-new-app'
            MnoeApps.list().then(
              (response) ->
                apps = $ctrl.resolve.enabledApps
                # Copy the response, we're are modifying the response in place and
                # don't want to modify the cached version in MnoeApps
                resp = angular.copy(response)
                enabledIds = _.map(apps, 'id')
                _.remove(resp.data, (app)-> _.includes(enabledIds, app.id))
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
    filterProducts = ->
      if $ctrl.searchTerm?.length > 0
        term = $ctrl.searchTerm.toLowerCase()
        $ctrl.filteredProducts = (product for product in $ctrl.products when product.name?.toLowerCase().indexOf(term) > -1)
      else if $ctrl.selectedCategory?.length > 0
        $ctrl.filteredProducts = (product for product in $ctrl.products when $ctrl.selectedCategory in (product.categories || []))
      else
        $ctrl.filteredProducts = $ctrl.products

    $ctrl.onSearchChange = () ->
      $ctrl.selectedCategory = ''
      filterProducts()

    $ctrl.onCategoryChange = () ->
      $ctrl.searchTerm = ''
      filterProducts()

    $ctrl.toolTipText = (product) ->
      # Return tooltip text for each product.
      # product.disabledToolTip is not to be set
      # unless the product is to be disabled
      product.disabledToolTip || product.tiny_description


    # Select or deselect a product
    $ctrl.toggleProduct = (product) ->
      if product.checked
        _.remove($ctrl.selectedProducts, product)
      else
        # Don't allow more than one product to be selected unless $ctrl.multiple is true,
        # or if ordering is disabled for a specific product.
        return if (!$ctrl.multiple && $ctrl.selectedProducts.length > 0) || product.orderDisabled
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
