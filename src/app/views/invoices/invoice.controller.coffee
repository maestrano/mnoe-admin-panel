@App.controller 'InvoiceController', ($stateParams, $uibModal, $window, $state, MnoeAdminConfig, MnoeInvoices, toastr, DatesHelper) ->
  'ngInject'
  vm = this

  # -----------------------------------------------------------------
  # Initialize
  # -----------------------------------------------------------------
  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  vm.isLoading = true
  vm.invoice = {}
  vm.invoice.adjustments = []
  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain()
      vm.isInvoiceEditedPaid = angular.copy(vm.invoice.invoice.paid_at)
  ).finally(-> vm.isLoading = false)

  # -----------------------------------------------------------------
  # Invoice Management
  # -----------------------------------------------------------------
  vm.downloadInvoice = (slug) ->
    $window.location.href = '/mnoe/admin/invoices/' + slug

  # The expected date is the 2nd of the month following the invoice period
  vm.expectedPaymentDate = (endOfInvoiceDate) ->
    DatesHelper.expectedPaymentDate(endOfInvoiceDate)

  vm.changeInvoiceStatus = () ->
    vm.invoice.invoice.paid_at = moment().toISOString()

  vm.update = () ->
    vm.isLoading = true
    MnoeInvoices.update(vm.invoice.invoice).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.invoice.details.status_change')
    ).finally(-> vm.isLoading = false)
    MnoeInvoices.addAdjustment(vm.invoice.invoice).then(
      (response) ->
    )
    $state.go('dashboard.invoices')

  # -----------------------------------------------------------------
  #  Adjustment Management
  # -----------------------------------------------------------------
  vm.openAddAdjustmentModal = () ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/adjustment-modal.html'
      controller: 'CreateAdjustmentController'
      controllerAs: 'vm'
    )
    modalInstance.result.then(
      (adjustment) ->
        # Add the adjustment adjustment
        vm.invoice.adjustments.push(adjustment)
    )

  vm.openEditAdjustmentModal = (adjustment) ->
    vm.oldAdjustment = angular.copy(adjustment)
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/adjustment-modal.html'
      controller: 'EditAdjustmentController'
      controllerAs: 'vm'
      resolve:
        adjustment: vm.oldAdjustment
    )
    modalInstance.result.then(
      (adjustmentEdited) ->
        # If the adjustment is modified
        if adjustmentEdited
          indexOfAdjustment = vm.invoice.adjustments.indexOf(adjustment)
          vm.invoice.adjustments.splice(indexOfAdjustment, 1)
          vm.invoice.adjustments.push(adjustmentEdited)
    )
  
  vm.openDeleteAdjustmentModal = (adjustment) ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/delete-adjustment.html'
      controller: 'DeleteAdjustmentController'
      controllerAs: 'vm'
    )
    modalInstance.result.then(
      (deletion) ->
        # If user delete the adjustment
        if deletion
          indexOfAdjustment = vm.invoice.adjustments.indexOf(adjustment)
          vm.invoice.adjustments.splice(indexOfAdjustment, 1)
    )

  return
