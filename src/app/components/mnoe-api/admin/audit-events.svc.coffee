# Service for managing the Audit Log.
@App.service 'MnoeAuditEvents', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all("audit_events").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        notifyListObservers(promise)
        response
    )

  observerCallbacks = []

  # Subscribe callback functions to be called if 'list' has been changed
  @registerListChangeCb = (callback) ->
    observerCallbacks.push(callback)

  # Call this when you know 'list' has been changed
  notifyListObservers = (listPromise) ->
    _.forEach observerCallbacks, (callback) ->
      callback(listPromise)

  return @
