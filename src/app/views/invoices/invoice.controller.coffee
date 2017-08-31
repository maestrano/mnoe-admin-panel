@App.controller 'InvoiceController', ($stateParams, MnoeAdminConfig, MnoeInvoices) ->
  'ngInject'
  vm = this

  vm.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
  vm.invoice = {}
  MnoeInvoices.get($stateParams.invoiceId).then(
    (response) ->
      vm.invoice = response.data.plain().invoice
      vm.organization = response.data.plain().organization
      vm.bills = response.data.plain().bills
  ).finally(-> )

  # The expected date is the 2nd of the month following the invoice period
  vm.calculatePaymentDate = (endOfInvoiceDate) ->
    # calculate day of end of invoiced period
    endOfInvoicePeriod = new Date(endOfInvoiceDate)
    # calculate 2nd of the last month invoiced
    secondOftheEndOfInvoicePeriod = new Date(endOfInvoicePeriod.getFullYear(), endOfInvoicePeriod.getMonth(), 2)
    # if the 2nd of the month invoiced is > period invoiced, return second of the same month
    if endOfInvoicePeriod < secondOftheEndOfInvoicePeriod
      secondOftheEndOfInvoicePeriod
    else
      # if the 2nd of the month invoiced is < of period invoiced, return second of the following month
      secondOfNextMonth = new Date(secondOftheEndOfInvoicePeriod.getFullYear(), secondOftheEndOfInvoicePeriod.getMonth()+1, 3)
      secondOfNextMonth


  return
