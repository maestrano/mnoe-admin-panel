@App.controller 'InvoiceController', ($stateParams, MnoeAdminConfig, MnoeInvoices, DatesHelper) ->
  'ngInject'
  vm = this

  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain().invoice
      vm.organization = response.data.plain().organization
      vm.bills = response.data.plain().bills
  ).finally(-> )

  # The expected date is the 2nd of the month following the invoice period
  vm.expectedPaymentDate = (endOfInvoiceDate) ->
    DatesHelper.expectedPaymentDate(endOfInvoiceDate)

  return
