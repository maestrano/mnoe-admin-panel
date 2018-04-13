@App.controller 'ProductsController', ($state, MnoeProducts, MnoeProvisioning, MnoConfirm, MnoeCurrentUser) ->
  'ngInject'

  vm = this
  vm.product = {}

  MnoeCurrentUser.getUser().then(
    (response) ->
      vm.isAccountManager = (response.admin_role == 'staff')
  )

  vm.createProduct = () ->
    modalOptions =
      headerText: 'mnoe_admin_panel.dashboard.product.create_product_modal.title'
      bodyText: 'mnoe_admin_panel.dashboard.product.create_product_modal.body'
      inputTextEnabled: true
      inputTextPlaceholder: 'Product title'
      closeButtonText: 'mnoe_admin_panel.dashboard.product.create_product_modal.cancel'
      actionButtonText: 'mnoe_admin_panel.dashboard.product.create_product_modal.create'
      actionCb: (input) ->
        vm.product.name = input
        MnoeProducts.create(vm.product).then(
          (response) ->
            response = response.data.plain()
            vm.productId = response.product.id
            $state.go('dashboard.product',({productId: vm.productId}))
          ->
            toastr.error('mnoe_admin_panel.dashboard.product.create_product_modal.create_error')
      )
      type: 'primary'

    MnoConfirm.showModal(modalOptions)

  return vm
