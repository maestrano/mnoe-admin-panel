# Service for managing the tenant.
@App.service 'MnoeTenant', (MnoeAdminApiSvc) ->
  _self = @

  @get = () ->
    MnoeAdminApiSvc.one('tenant').get()

  @update = (config) ->
    MnoeAdminApiSvc.one('tenant').patch(tenant: {frontend_config: config})

  @updatePluginsConfig = (config) ->
    MnoeAdminApiSvc.one('tenant').patch(tenant: {plugins_config: config})

  @updateDomain = (params) ->
    MnoeAdminApiSvc.one('tenant').one('domain').patch(tenant: params)

  @addSSLCerts = (params) ->
    MnoeAdminApiSvc.one('tenant').all('ssl_certificates').post(tenant: params)

  return @
