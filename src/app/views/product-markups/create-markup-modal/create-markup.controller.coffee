@App.controller 'CreateMarkupController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeProductMarkups, MnoeProducts, MnoeOrganizations, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.nbItems = 10
  vm.debounce_time = 100
  vm.markup = {}
  vm.products = []
  vm.companies = []

  vm.onSubmit = () ->
    vm.isLoading = true

    MnoeProductMarkups.addProductMarkup(vm.markup).then(
      (success) ->
        toastr.success("mnoe_admin_panel.dashboard.product_markups.add_markup.modal.toastr_success", {preventDuplicates: false})
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.data)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.product_markups.add_markup.modal.toastr_error', {preventDuplicates: false})
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  vm.fetchProducts = (search) ->
    return MnoeProducts.products(vm.nbItems, 0, 'name', {'where[name.like]' : search + '%'}).then(
      (response) ->
        vm.products = response.data
        vm.products.unshift({id: 0, name: $filter('translate')("mnoe_admin_panel.dashboard.product_markups.add_markup.modal.all_products")})
    )

  vm.fetchCompanies = (search) ->
    return MnoeOrganizations.organizations(vm.nbItems, 0, 'name', {'where[name.like]' : search + '%'}).then(
      (response) ->
        vm.companies = response.data
        vm.companies.unshift({id: 0, name: $filter('translate')("mnoe_admin_panel.dashboard.product_markups.add_markup.modal.all_companies")})
    )

  vm.lazyFetchProducts = _.debounce vm.fetchProducts, vm.debounce_time
  vm.lazyFetchCompanies = _.debounce vm.fetchCompanies, vm.debounce_time

  vm.toggleProductFilter = (product) ->
    vm.markup.product_id = product.originalObject.id

  vm.toggleCompanyFilter = (company) ->
    vm.markup.organization_id = company.originalObject.id

  # Fetch initial drop down
  vm.fetchProducts('')
  vm.fetchCompanies('')

  return
