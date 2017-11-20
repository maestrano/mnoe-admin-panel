@App.service 'MnoeTeams', ($q, MnoeAdminApiSvc, toastr, MnoErrorsHandler) ->

  @list = (organization_id,limit, offset, sort) ->
    params = {}
    params['order_by'] = sort
    params['limit'] = limit
    params['offset'] = offset
    teamsApi(organization_id).getList(params).catch(
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.teams_list.toastr_error')
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @search = (organization_id, terms) ->
    teamsApi(organization_id).getList({terms: terms})

  teamsApi = (id) ->
    MnoeAdminApiSvc.one('organizations', id).all('teams')

  return @
