# Service for managing the users.
@App.service 'MnoeSubTenants', (MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  @list = (limit, offset, sort) ->
    MnoeAdminApiSvc.all("sub_tenants").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        response
    )

  @get = (id) ->
    MnoeAdminApiSvc.one('sub_tenants', id).get()

  @create = (subTenant) ->
    promise = MnoeAdminApiSvc.all('sub_tenants').post(subTenant).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantAdded, promise)
        response
    )

  # filtering an object with an array in coffeescript
  filterElements = (validate, filter) ->
    filtered = {}
    for key, value of validate
      if key in filter then filtered[key] = value
    filtered

  @update = (subTenant) ->
    data = {sub_tenant: filterElements(subTenant, ["name", "client_ids", "account_manager_ids"])}
    promise = MnoeAdminApiSvc.one('sub_tenants', subTenant.id).patch(data).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
        response
    )

  @delete = (id) ->
    promise = MnoeAdminApiSvc.one('sub_tenants', id).doDELETE().then(
      ->
        MnoeObservables.notifyObservers(OBS_KEYS.subTenantChanged, promise)
      (error) ->
        $log.error('Error while deleting subTenant: ' + id, error)
    )

  return @
