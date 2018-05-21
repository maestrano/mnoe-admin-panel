@App.controller 'ProductsController', ($state, $translate, MnoeProducts, MnoeProvisioning, MnoConfirm, MnoeCurrentUser, URL_CONFIG, UserRoles) ->
  'ngInject'

  vm = this
  vm.product = {}
  vm.developerOnboardingURL = URL_CONFIG.developer_onboarding_url

  MnoeCurrentUser.getUser().then(
    (response) ->
      vm.isAccountManager = UserRoles.isAccountManager(response)
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

    if vm.developerOnboardingURL
      modalOptions.additionalBodyHtml = "<a href='#{vm.developerOnboardingURL}' target='_blank'>" \
      + $translate.instant('mnoe_admin_panel.dashboard.product.create_product_modal.developer_onboarding_link_text') \
      + "</a>"

    MnoConfirm.showModal(modalOptions)

  return vm
