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
  controller: ($window, orderByFilter, MnoeProducts) ->
    'ngInject'

    $ctrl = this

    $ctrl.$onInit = ->
      $ctrl.products = orderByFilter($ctrl.resolve.products.data, 'name')
      $ctrl.multiple = $ctrl.resolve.multiple
      $ctrl.modalHeight = ($window.innerHeight - 200) + "px"
      $ctrl.selectedProducts = []
      $ctrl.headerText = $ctrl.resolve.headerText || 'mnoe_admin_panel.components.mno-product-selector.title'
      $ctrl.actionButtonText = $ctrl.resolve.actionButtonText || 'mnoe_admin_panel.components.mno-product-selector.create_order'

    # Select or deselect a product
    $ctrl.toggleProduct = (product) ->
      if product.checked
        _.remove($ctrl.selectedProducts, product)
      else
        return if (!$ctrl.multiple && $ctrl.selectedProducts.length > 0)
        $ctrl.selectedProducts.push(product)
      product.checked = !product.checked

    # Close the modal and return the selected product
    $ctrl.closeModal = ->
      $ctrl.isLoadingProduct = true
      MnoeProducts.get($ctrl.selectedProducts[0].id).then(
        (response) ->
          $ctrl.close({$value: response.data})
      ).finally(-> $ctrl.isLoadingProduct = false)

    $ctrl.dismissModal = ->
      $ctrl.dismiss()

    return
})
