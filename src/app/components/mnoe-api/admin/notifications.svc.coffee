@App.service 'MnoeNotifications', (MnoeAdminApiSvc) ->

  @get = (params = {})->
    MnoeAdminApiSvc.all('notifications').getList(params)

  @notified = (params)->
    MnoeAdminApiSvc.one('notifications').post('/notified', params)

  return @
