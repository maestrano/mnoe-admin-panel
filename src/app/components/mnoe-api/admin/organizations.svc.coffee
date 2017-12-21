# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    promise = MnoeAdminApiSvc.all("organizations").getList(params).then(
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

  @organizations = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("organizations").getList(params)

  @search = (terms, params = {}) ->
    params['terms'] = terms
    MnoeAdminApiSvc.all("organizations").getList(params)

  @inArrears = () ->
    MnoeAdminApiSvc.all('organizations').all('in_arrears').getList()

  @get = (id) ->
    MnoeAdminApiSvc.one('organizations', id).get()

  @count = () ->
    MnoeAdminApiSvc.all('organizations').customGET('count')

  @create = (organization) ->
    MnoeAdminApiSvc.all('/organizations').post(organization)

  @update = (organization) ->
    MnoeAdminApiSvc.one('/organizations', organization.id).patch(organization)

  @freeze = (organization) ->
    MnoeAdminApiSvc.one('organizations', organization.id).customPUT(null, '/freeze')

  @unfreeze = (organization) ->
    MnoeAdminApiSvc.one('organizations', organization.id).customPUT(null, '/unfreeze')

  return @
