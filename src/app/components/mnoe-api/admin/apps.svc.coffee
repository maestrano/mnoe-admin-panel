# Service for managing the App catalogue.
@App.service 'MnoeApps', ($q, toastr, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS, MnoErrorsHandler) ->
  _self = @

  appsPromise = null
  subscribedTenantAppsPromise = null

  @list = (params = {})->
    return appsPromise if appsPromise?
    appsPromise = MnoeAdminApiSvc.all('apps').getList(params).catch(
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.settings.apps.retrieve.error')
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @subscribedTenantAppsList = (params = {})->
    return subscribedTenantAppsPromise if subscribedTenantAppsPromise?
    subscribedTenantAppsPromise = MnoeAdminApiSvc.all('products').all('subscribed_tenant_products').getList(params).catch(
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.my-tools.apps.retrieve.error')
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  # Delete the instance of an app
  @disable = (id) ->
    MnoeAdminApiSvc.one('apps', id).customPATCH(null, 'disable').then(
      -> MnoeObservables.notifyObservers(OBS_KEYS.marketplaceChanged, null)
    )

  @enable = (id) ->
    MnoeAdminApiSvc.one('apps', id).customPATCH(null, 'enable').then(
      -> MnoeObservables.notifyObservers(OBS_KEYS.marketplaceChanged, null)
    )

  @enableMultiple = (ids) ->
    return $q.reject('no apps specified') unless ids.length >= 1

    if ids.length == 1
      _self.enable(ids[0])
    else
      MnoeAdminApiSvc.all('apps').customPATCH(ids: ids, 'enable').then(
        -> MnoeObservables.notifyObservers(OBS_KEYS.marketplaceChanged, null)
      )

  return @
