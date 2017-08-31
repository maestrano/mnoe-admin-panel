@App.component('mnoeInvoicesList', {
  templateUrl: 'app/components/mnoe-invoices-list/mnoe-invoices-list.html',
  bindings: {
    view: '@',
  }
  controller: ($state, MnoeInvoices) ->
    ctrl = this

    ctrl.invoices =
      list: []
      nbItems: 10
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.invoices.nbItems = nbItems
        ctrl.invoices.page = page
        ctrl.invoices.offset = (page  - 1) * nbItems
        fetchInvoices(nbItems, ctrl.invoices.offset)

    # Server call
    ctrl.callServer = (tableState) ->
      fetchInvoices(ctrl.invoices.nbItems, ctrl.invoices.offset)

    # go to single invoice view
    ctrl.goToInvoice = (invoiceId) ->
      $state.go('dashboard.invoice', {invoiceId: invoiceId})

    # Fetch invoices
    fetchInvoices = (limit, offset) ->
      ctrl.invoices.loading = true
      return MnoeInvoices.list(limit, offset).then(
        (response) ->
          ctrl.invoices.totalItems = response.headers('x-total-count')
          ctrl.invoices.list = response.data
      ).finally(-> ctrl.invoices.loading = false)

    return

})
