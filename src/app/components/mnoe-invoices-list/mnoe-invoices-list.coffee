@App.component('mnoeInvoicesList', {
  templateUrl: 'app/components/mnoe-invoices-list/mnoe-invoices-list.html'

  controller: ($state, MnoeAdminConfig, MnoeInvoices, DatesHelper) ->
    ctrl = this

    ctrl.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
    ctrl.invoices =
      list: []
      nbItems: 10
      search: {}
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.invoices.nbItems = nbItems
        ctrl.invoices.page = page
        ctrl.invoices.offset = (page  - 1) * nbItems
        fetchInvoices(nbItems, ctrl.invoices.offset)

    # Server call
    ctrl.callServer = (tableState) ->
      search = updateSearch (tableState.search)
      fetchInvoices(ctrl.invoices.nbItems, ctrl.invoices.offset)

    # Update searching parameters
    updateSearch = (searchingState = {}) ->
      search = {}
      if searchingState.predicateObject
        for attr, value of searchingState.predicateObject
          search[ 'where[' + attr + '.like]' ] = value + '%'

      ctrl.invoices.search = search
      return search

    # The expected date is the 2nd of the month following the invoice period
    ctrl.expectedPaymentDate = (endOfInvoiceDate) ->
      DatesHelper.expectedPaymentDate(endOfInvoiceDate)

    # go to single invoice view
    ctrl.goToInvoice = (invoiceId) ->
      $state.go('dashboard.invoice', {invoiceId: invoiceId})

    # Fetch invoices
    fetchInvoices = (limit, offset, search = ctrl.invoices.search) ->
      ctrl.invoices.loading = true
      return MnoeInvoices.list(limit, offset, search).then(
        (response) ->
          ctrl.invoices.totalItems = response.headers('x-total-count')
          ctrl.invoices.list = response.data
      ).finally(-> ctrl.invoices.loading = false)

    return

})
