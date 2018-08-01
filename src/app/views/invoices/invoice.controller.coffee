@App.controller 'InvoiceController', ($stateParams, $uibModal, $window, $state, $log, toastr, MnoeAdminConfig, MnoeInvoices, DatesHelper, MnoConfirm) ->
  'ngInject'
  vm = this

  # -----------------------------------------------------------------
  # Initialize
  # -----------------------------------------------------------------
  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  vm.isLoading = true
  vm.editableTaxRate = false
  vm.invoice = {}

  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain().invoice
      vm.isInvoiceEditedPaid = angular.copy(vm.invoice.paid_at)
      vm.invoice.adjustments = [] unless vm.invoice.adjustments?
  ).finally(-> vm.isLoading = false)

  # -----------------------------------------------------------------
  # Invoice Management
  # -----------------------------------------------------------------
  vm.downloadInvoice = (slug, event) ->
    $window.open('/mnoe/admin/invoices/' + slug, '_blank')
    # avoid change to single invoice view when click in this cell
    event.stopPropagation()

  # The expected date is the 2nd of the month following the invoice period
  vm.expectedPaymentDate = (endOfInvoiceDate) ->
    DatesHelper.expectedPaymentDate(endOfInvoiceDate)

  vm.changeInvoiceStatus = () ->
    vm.invoice.paid_at = moment().toISOString()

  vm.editTaxRate = () ->
    vm.invoice_tax_rate = vm.invoice.tax_pips_applied / 100
    vm.editableTaxRate = true

  vm.updateTaxRate = () ->
    vm.invoice.tax_pips_applied = vm.invoice_tax_rate * 100
    vm.editableTaxRate = false

  vm.cancelTaxRateUpdate = () ->
    vm.editableTaxRate = false

  vm.update = () ->
    vm.isLoading = true
    MnoeInvoices.update(vm.invoice).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.invoice.details.updated')
    ).finally(-> vm.isLoading = false)
    $state.reload()

  # -----------------------------------------------------------------
  #  Adjustment Management
  # -----------------------------------------------------------------
  vm.openAddAdjustmentModal = () ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/invoices/modals/adjustment-modal.html'
      controller: 'CreateAdjustmentController'
      controllerAs: 'vm'
      backdrop: 'static'
      keyboard: false
      resolve:
        invoice: vm.invoice
    )
    modalInstance.result.then(
      (result) ->
        if result
          vm.invoice.adjustments.push(result.adjustment)
          vm.invoice.price = result.invoice.price

    )

  vm.openDeleteAdjustmentModal = (adjustment) ->
    modalOptions =
      headerText: 'mnoe_admin_panel.dashboard.invoice.delete_adjustments.are_you_sure'
      bodyText: 'mnoe_admin_panel.dashboard.invoice.delete_adjustments.you_will_not'
      closeButtonText: 'mnoe_admin_panel.dashboard.invoice.delete_adjustments.cancel'
      actionButtonText: 'mnoe_admin_panel.dashboard.invoice.delete_adjustments.delete'
      type: 'danger'

    MnoConfirm.showModal(modalOptions).then( ->
      vm.isLoading = true
      MnoeInvoices.deleteAdjustment(vm.invoice.id, adjustment.id).then(
        (response) ->
          indexOfAdjustment = vm.invoice.adjustments.indexOf(adjustment)
          vm.invoice.adjustments.splice(indexOfAdjustment, 1)
          toastr.success('mnoe_admin_panel.dashboard.invoice.delete_adjustments.toastr_success')
          vm.invoice.price = response.data.invoice.price
        (error) ->
          $log.error('Error while deleting adjustment', error)
          # Display an error
          msg = if error?.data?.invoice
            'mnoe_admin_panel.dashboard.invoice.adjustments.negative_invoice_error'
          else
            'mnoe_admin_panel.dashboard.invoice.delete_adjustments.toastr_error'
          toastr.error(msg)
      ).finally(-> vm.isLoading = false)
    )

  vm.sendInvoiceToCustomer = () ->
    MnoeInvoices.sendInvoiceToCustomer(vm.invoice.id).then( ->
      (success) ->
        toastr.success('mnoe_admin_panel.dashboard.invoice.send_invoice.toastr_success')
      (error) ->
        # Display an error
        $log.error('Error while sending email', error)
        toastr.error('mnoe_admin_panel.dashboard.invoice.send_invoice.toastr_error')
    )

  return
