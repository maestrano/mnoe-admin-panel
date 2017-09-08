@App.controller 'CreateAdjustmentController', ($uibModalInstance, MnoeInvoices, toastr, invoice) ->
  'ngInject'
  vm = this

  vm.adjustment = {currency: invoice.price.currency.iso_code}
  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.addAdjustment = () ->
    MnoeInvoices.addAdjustment(invoice.id, vm.adjustment).then(
      (success) ->
        # Close the modal returning the item to the parent window
        vm.adjustment.id = success.data.id
        vm.adjustment.end_user_price_cents = vm.adjustment.price_cents
        toastr.success("mnoe_admin_panel.dashboard.invoice.create_adjustments.toastr_success", {preventDuplicates: false})
        $uibModalInstance.close({adjustment: vm.adjustment, invoice: success.data.invoice})
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.invoice.create_adjustments.toastr_error', {preventDuplicates: false})
        $log.error("An error occurred:", error)
        $uibModalInstance.close(vm.adjustment)
    )

  return
