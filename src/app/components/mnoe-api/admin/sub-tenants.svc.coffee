# Service for managing the users.
@App.service 'MnoeSubTenants', ($log, MnoErrorsHandler, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  @list = (limit, offset, sort) ->
    MnoeAdminApiSvc.all("sub_tenants").getList({order_by: sort, limit: limit, offset: offset})

  @get = (id) ->
    MnoeAdminApiSvc.one('sub_tenants', id).get()

  @create = (subTenant) ->
    promise = MnoeAdminApiSvc.all('sub_tenants').post(subTenant).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantAdded, promise)
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  @update = (subTenant) ->
    data = {sub_tenant: _.pick(subTenant, ["name", "client_ids", "account_manager_ids"])}
    promise = MnoeAdminApiSvc.one('sub_tenants', subTenant.id).patch(data).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  @delete = (id) ->
    promise = MnoeAdminApiSvc.one('sub_tenants', id).doDELETE().then(
      ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  return @
