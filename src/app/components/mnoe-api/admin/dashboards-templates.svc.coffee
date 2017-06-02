# Service for managing the Audit Log.
@App.service 'MnoeDashboardTemplates', (MnoeAdminApiSvc) ->
  _self = @

  @list = () ->
    promise = MnoeAdminApiSvc.all("/dashboard_templates").getList().then(
      (response) ->
        notifyListObservers(promise)
        response
    )

  observerCallbacks = []

  @delete = (dashboardTemplateId) ->
    promise = MnoeAdminApiSvc.one("dashboard_templates", dashboardTemplateId).remove().then(
      (response) ->
        notifyListObservers(promise)
        response
    )

  # Call this when you know 'list' has been changed
  notifyListObservers = (listPromise) ->
    _.forEach observerCallbacks, (callback) ->
      callback(listPromise)

  return @
