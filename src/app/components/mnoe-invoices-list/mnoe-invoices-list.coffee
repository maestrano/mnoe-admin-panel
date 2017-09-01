@App.component('mnoeInvoicesList', {
  templateUrl: 'app/components/mnoe-invoices-list/mnoe-invoices-list.html'

  controller: ($state, MnoeAdminConfig, MnoeInvoices) ->
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
    ctrl.calculatePaymentDate = (endOfInvoiceDate) ->
      # calculate day of end of invoiced period
      endOfInvoicePeriod = moment(endOfInvoiceDate, 'YYYY-M-D')
      # calculate 2nd of the last month invoiced
      secondOftheEndOfInvoicePeriod = moment(endOfInvoicePeriod, 'YYYY-M-D').startOf('month').add(1, 'day')
      # if the 2nd of the month invoiced is > period invoiced, return second of the same month
      if endOfInvoicePeriod < secondOftheEndOfInvoicePeriod
        secondOftheEndOfInvoicePeriod
      else
      # if the 2nd of the month invoiced < of period invoiced, return second of the following month
        secondOfNextMonth = moment(endOfInvoicePeriod, 'YYYY-M-D').startOf('month').add(1, 'month').add(1, 'day')
        secondOfNextMonth

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
