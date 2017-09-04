@App.controller 'InvoiceController', ($stateParams, MnoeAdminConfig, MnoeInvoices, toastr, DatesHelper) ->
  'ngInject'
  vm = this

  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  vm.isLoading = true
  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain().invoice
      vm.organization = response.data.plain().organization
      vm.bills = response.data.plain().bills
      vm.billing_summary = response.data.plain().billing_summary
  ).finally(-> vm.isLoading = false)

  vm.changeInvoiceStatus = () ->
    vm.isLoading = true
    vm.invoice.paid_at = moment().toISOString()
    MnoeInvoices.update(vm.invoice).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.invoice.details.status_change')
    ).finally(-> vm.isLoading = false)

  # The expected date is the 2nd of the month following the invoice period
  vm.expectedPaymentDate = (endOfInvoiceDate) ->
    DatesHelper.expectedPaymentDate(endOfInvoiceDate)

  return
