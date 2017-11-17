@App.service 'MnoeTeams', ($q, MnoeAdminApiSvc, toastr, MnoErrorsHandler) ->

  @list = (organization_id,limit, offset, sort) ->
    params = {}
    params['order_by'] = sort
    params['limit'] = limit
    params['offset'] = offset
    MnoeAdminApiSvc.one('organizations', organization_id).all('teams').getList(params).catch(
      (error) ->
        # Something went wrong
        toastr.error()
        MnoErrorsHandler.processServerError()
        $q.reject(error)
    )

  return @
