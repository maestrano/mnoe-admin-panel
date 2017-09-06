@App.controller 'InvoiceController', ($stateParams, $uibModal, $window, MnoeAdminConfig, MnoeInvoices, toastr, DatesHelper) ->
  'ngInject'
  vm = this

  # -----------------------------------------------------------------
  # Initialize
  # -----------------------------------------------------------------
  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  vm.isLoading = true
  vm.invoice = {}
  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain()
  ).finally(-> vm.isLoading = false)

  # -----------------------------------------------------------------
  # Invoice Management
  # -----------------------------------------------------------------
  vm.downloadInvoice = (slug) ->
    $window.location.href = '/mnoe/admin/invoices/' + slug

  # The expected date is the 2nd of the month following the invoice period
  vm.expectedPaymentDate = (endOfInvoiceDate) ->
    DatesHelper.expectedPaymentDate(endOfInvoiceDate)

  # -----------------------------------------------------------------
  #  Invoice status
  # -----------------------------------------------------------------
  vm.changeInvoiceStatus = () ->
    vm.isLoading = true
    vm.invoice.paid_at = moment().toISOString()
    MnoeInvoices.update(vm.invoice).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.invoice.details.status_change')
    ).finally(-> vm.isLoading = false)

  # -----------------------------------------------------------------
  #  Adjustments
  # -----------------------------------------------------------------
  vm.openAddAdjustmentModal = () ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/adjustment-modal.html'
      controller: 'CreateAdjustmentController'
      controllerAs: 'vm'
    )

  vm.openEditAdjustmentModal = (adjustment) ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/adjustment-modal.html'
      controller: 'EditAdjustmentController'
      controllerAs: 'vm'
      resolve:
        adjustment: adjustment
    )
  
  vm.openDeleteAdjustmentModal = (adjustmentId) ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/delete-adjustment.html'
      controller: 'DeleteAdjustmentController'
      controllerAs: 'vm'
    )

  return
