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
  controller: ($window, $q, orderByFilter, MnoeProducts, MnoeApps) ->
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
      $ctrl.headerText = $ctrl.resolve.headerText || 'mnoe_admin_panel.components.mno-product-selector.title'
      $ctrl.actionButtonText = $ctrl.resolve.actionButtonText || 'mnoe_admin_panel.components.mno-product-selector.create_order'

    $ctrl.resolveProducts = ->
      $ctrl.isLoadingProducts = true

      params = {
        skip_dependencies: true,
        fields: {
          products: ['name, logo']
        },
        'where[active]': true
      }
      $ctrl.isLoadingProducts = true

      promise =
        switch $ctrl.flag
          when 'organization-create-order'
            MnoeProducts.products(_, _, _, params)
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
          $ctrl.products = orderByFilter(response.data, 'name')
      ).finally(-> $ctrl.isLoadingProducts = false)

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

      promise = selectedProductsPromise()
      promise.then(
        (response) ->
          $ctrl.close({$value: response})
      ).finally(-> $ctrl.isLoadingProducts = false)

    $ctrl.dismissModal = ->
      $ctrl.dismiss()

    return
})
