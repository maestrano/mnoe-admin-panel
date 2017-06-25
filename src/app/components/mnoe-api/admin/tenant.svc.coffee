# Service for managing the tenant.
@App.service 'MnoeTenant', (MnoeAdminApiSvc) ->
  _self = @

  @get = () ->
    MnoeAdminApiSvc.one('tenant').get()

  @update = (config) ->
    MnoeAdminApiSvc.one('tenant').patch(tenant: {frontend_config: config})

  return @
