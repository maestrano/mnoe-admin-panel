# Service for managing the invoices.
@App.service 'MnoeInvoices', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, params = {}) ->
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.all('invoices').getList(params)

  @get = (id) ->
    MnoeAdminApiSvc.one('/invoices', id).get()

  @update = (invoice) ->
    MnoeAdminApiSvc.one('/invoices', invoice.id).patch({invoice: invoice})

  @currentBillingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('current_billing_amount')

  @lastInvoicingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('last_invoicing_amount')

  @outstandingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('outstanding_amount')

  @lastPortfolioAmount = ->
    MnoeAdminApiSvc.all('invoices').customGET('last_portfolio_amount')

  @lastCommissionAmount = ->
    MnoeAdminApiSvc.all('invoices').customGET('last_commission_amount')

  return @
