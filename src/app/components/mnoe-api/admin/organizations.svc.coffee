# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeAdminApiSvc, MnoeObservables, OBS_KEYS, ORG_REQUIREMENTS) ->
  _self = @

  @list = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.all("organizations").getList(params).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.orgChanged, response)
        response
    )

  @organizations = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("organizations").getList(params)

  @mainAddressRequired = ->
    'main_address' in ORG_REQUIREMENTS

  @search = (params) ->
    MnoeAdminApiSvc.all("organizations").getList(params)

  @supportSearch = (params) ->
    MnoeAdminApiSvc.all('organizations').all('support_search').getList(params)

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
