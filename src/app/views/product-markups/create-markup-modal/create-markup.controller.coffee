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

    vm.productMarkupExist().then(
      (exists) ->
        if !exists
          MnoeProductMarkups.addProductMarkup(vm.markup).then(
            (success) ->
              toastr.success("mnoe_admin_panel.dashboard.product_markups.add_markup.modal.toastr_success", {preventDuplicates: false})
              # Close the modal returning the item to the parent window
              $uibModalInstance.close(success.data)
            (error) ->
              toastr.error('mnoe_admin_panel.dashboard.product_markups.add_markup.modal.toastr_error', {preventDuplicates: false})
              $log.error("An error occurred:", error)
          ).finally(-> vm.isLoading = false)
        else
          $uibModalInstance.close()
          toastr.error('mnoe_admin_panel.dashboard.product_markups.add_markup.modal.already_exists', {preventDuplicates: false})
    )

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

  vm.productMarkupExist = () ->

    # _.pick removes null hashes
    MnoeProductMarkups.search(_.pick({'product.id': vm.markup.product_id, 'organization.id': vm.markup.organization_id}, _.identity)).then(
      (success) ->
        if success.data.length > 0
          if vm.markup.product_id? && vm.markup.organization_id?
            return true

          # filtering on null (org or product) does not work on mnoe side. Need to check manually if one of them is null
          exists = false
          _.each(success.data, (pm) ->
            if !vm.markup.product_id? && !pm.product && pm.organization.id == vm.markup.organization_id
              exists = true
            if !vm.markup.organization_id? && !pm.organization && pm.product.id == vm.markup.product_id
              exists = true
            if !vm.markup.product_id? && !vm.markup.organization_id? && !pm.product && !pm.organization
              exists = true
          )

        return exists
      (error) ->
        console.log(error)
        return false
    )

  return
