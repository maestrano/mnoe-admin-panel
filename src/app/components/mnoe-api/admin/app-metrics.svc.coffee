# Service for managing the apps.
@App.service 'MnoeAppMetrics', ($q, $log, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all('app_metrics').getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.appChanged, response)
        response
    )

  @search = (terms) ->
    MnoeAdminApiSvc.all('app_metrics').getList({terms: terms})

  @get = (id) ->
    MnoeAdminApiSvc.one('app_metrics', id).get()

  return @
