# Service for managing the users.
@App.service 'MnoeTasks', ($log, $q, toastr, MnoeAdminApiSvc) ->


  @get = (params = {})->
    MnoeAdminApiSvc.all('tasks').getList(params)

  @getRecipients = ->
    MnoeAdminApiSvc
      .all('orga_relations')
      .getList()
      .then(
        (response)-> response.data.plain()
    )

  @update = (id, params = {})->
    MnoeAdminApiSvc
      .one('tasks', id)
      .patch(params)
      .then(
        (response)-> response.data.plain().task
    )

  @create = (params = {})->
    MnoeAdminApiSvc
      .all('tasks')
      .post(params)
      .then(
        (response)-> response.data.plain()
    )

  return @
