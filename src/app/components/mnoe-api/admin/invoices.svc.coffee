# Service for managing the invoices.
@App.service 'MnoeInvoices', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset) ->
    promise = MnoeAdminApiSvc.all('invoices').getList({limit: limit, offset: offset}).then(
      (response) ->
        response
    )

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
