@App.controller 'CreateAdjustmentController', ($uibModalInstance, $log, MnoeInvoices, toastr, invoice) ->
  'ngInject'
  vm = this

  vm.adjustment = {currency: invoice.price.currency.iso_code}
  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.addAdjustment = () ->
    return if vm.isLoading

    vm.isLoading = true
    MnoeInvoices.addAdjustment(invoice.id, vm.adjustment).then(
      (success) ->
        # Close the modal returning the item to the parent window
        vm.adjustment.id = success.data.id
        vm.adjustment.end_user_price_cents = vm.adjustment.price_cents
        toastr.success("mnoe_admin_panel.dashboard.invoice.create_adjustments.toastr_success", {preventDuplicates: false})
        $uibModalInstance.close({adjustment: vm.adjustment, invoice: success.data.invoice})
      (error) ->
        $log.error("An error occurred:", error)
        msg = if error?.data?.invoice
          'mnoe_admin_panel.dashboard.invoice.adjustments.negative_invoice_error'
        else
          'mnoe_admin_panel.dashboard.invoice.create_adjustments.toastr_error'
        toastr.error(msg, {preventDuplicates: false})
        $uibModalInstance.close()
    ).finally(-> vm.isLoading = false)

  return
