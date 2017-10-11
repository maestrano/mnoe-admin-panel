# Service for managing the users.
@App.service 'MnoeSubTenants', ($q, $log, MnoErrorsHandler, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
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
        $q.reject(error)
    )

  @update = (subTenant) ->
    data = {sub_tenant: _.pick(subTenant, ["name", "client_ids", "account_manager_ids"])}
    promise = MnoeAdminApiSvc.one('sub_tenants', subTenant.id).patch(data).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @update_clients = (subTenant, changes) ->
    data = {sub_tenant: changes}
    promise = MnoeAdminApiSvc.one('sub_tenants', subTenant.id).customPATCH(data, 'update_clients').then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.organizationChanged, promise)
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @update_account_managers = (subTenant, changes) ->
    data = {sub_tenant: changes}
    promise = MnoeAdminApiSvc.one('sub_tenants', subTenant.id).customPATCH(data, 'update_account_managers').then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffChanged, promise)
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @delete = (id) ->
    promise = MnoeAdminApiSvc.one('sub_tenants', id).doDELETE().then(
      ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  return @
