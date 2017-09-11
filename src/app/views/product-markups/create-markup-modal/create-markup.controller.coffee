@App.controller 'CreateMarkupController', ($scope, $filter, $stateParams, $log, $uibModalInstance, toastr, MnoeProductMarkups, MnoeProducts, MnoeOrganizations, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.nbItems = 10
  vm.debounce_time = 100
  vm.markup = {}
  vm.products = []
  vm.companies = []
  vm.markup.product_id = null
  vm.markup.organization_id = null

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

  vm.searchProducts = (search, timeoutPromise) ->
    return MnoeProducts.products(vm.nbItems, 0, 'name', {'where[name.like]' : search + '%'})

  vm.searchCompanies = (search, timeoutPromise) ->
    return MnoeOrganizations.organizations(vm.nbItems, 0, 'name', {'where[name.like]' : search + '%'})

  vm.toggleProductFilter = (product) ->
    vm.markup.product_id = product.originalObject.id

  vm.toggleCompanyFilter = (company) ->
    vm.markup.organization_id = company.originalObject.id

  return
