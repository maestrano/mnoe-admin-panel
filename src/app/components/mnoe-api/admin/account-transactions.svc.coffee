# Service for managing the users.
@App.service 'MnoeAccountTransactions', (MnoeAdminApiSvc) ->
  _self = @

  @create = (account_transaction) ->
    MnoeAdminApiSvc.all('/account_transactions').post(account_transaction)

  return @
