# Service for managing the apps.
@App.service 'MnoeAppkpis', ($q, $log, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all('appkpis').getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.appChanged, response)
        response
    )

  @search = (terms) ->
    MnoeAdminApiSvc.all('appkpis').getList({terms: terms})

  @get = (id) ->
    MnoeAdminApiSvc.one('appkpis', id).get()

  return @
