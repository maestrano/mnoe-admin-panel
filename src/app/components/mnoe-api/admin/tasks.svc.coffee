# Service for managing the users.
@App.service 'MnoeTasks', ($log, $q, toastr, MnoeAdminApiSvc) ->
  _self = @

  @get = (params = {})->
    MnoeAdminApiSvc.all('tasks').getList(params)

  @getRecipients = ->
    MnoeAdminApiSvc
      .all('orga_relations')
      .getList()
      .then(
        # TODO: XDE -> XLO: Hack to be able to show user first name, last name and orga. Please correct mno-ui-element to accept a recipient renderer
        # or just accept an hash id, name
        (response)-> _.map(response.data.plain(), (orgaRel) -> {id: orgaRel.id, user: {name: orgaRel.user.name + " " + orgaRel.user.surname + " ("+ orgaRel.user.email +  ") from " + orgaRel.organization.name}})
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
