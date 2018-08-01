@App.component('mnoeInvoicesList', {
  templateUrl: 'app/components/mnoe-invoices-list/mnoe-invoices-list.html'

  controller: ($state, $window, MnoeAdminConfig, MnoeInvoices, DatesHelper) ->
    ctrl = this

    # -----------------------------------------------------------------
    # Initialize
    # -----------------------------------------------------------------
    ctrl.isPaymentEnabled = MnoeAdminConfig.isPaymentEnabled()
    ctrl.invoices =
      list: []
      nbItems: 10
      search: ''
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.invoices.nbItems = nbItems
        ctrl.invoices.page = page
        ctrl.invoices.offset = (page  - 1) * nbItems
        fetchInvoices(nbItems, ctrl.invoices.offset)

    ctrl.searchChange = ->
      if ctrl.invoices.search && ctrl.invoices.search.length > 2
        fetchInvoices(ctrl.invoices.nbItems, ctrl.invoices.offset)

    # Fetch invoices
    fetchInvoices = (limit, offset, query_param = ctrl.invoices.search) ->
      ctrl.invoices.loading = true
      search = {}
      search[ 'where[slug.like]' ] = "#{query_param}%" if query_param
      return MnoeInvoices.list(limit, offset, search).then(
        (response) ->
          ctrl.invoices.totalItems = response.headers('x-total-count')
          ctrl.invoices.list = response.data
      ).finally(-> ctrl.invoices.loading = false)
    fetchInvoices(ctrl.invoices.nbItems, ctrl.invoices.offset)

    # -----------------------------------------------------------------
    # Invoice Management
    # -----------------------------------------------------------------

    # The expected date is the 2nd of the month following the invoice period
    ctrl.expectedPaymentDate = (endOfInvoiceDate) ->
      DatesHelper.expectedPaymentDate(endOfInvoiceDate)

    # go to single invoice view
    ctrl.goToInvoice = (invoiceId) ->
      $state.go('dashboard.invoice', {invoiceId: invoiceId})

    ctrl.downloadInvoice = (slug, event) ->
      $window.open('/mnoe/admin/invoices/' + slug, '_blank')
      # avoid change to single invoice view when click in this cell
      event.stopPropagation()

    return

})
