@App.service 'MnoeTeams', ($q, MnoeAdminApiSvc, toastr, MnoErrorsHandler) ->

  @list = (organization_id) ->
    MnoeAdminApiSvc.one('organizations', organization_id).all('teams').getList().catch(
      (error) ->
        # Something went wrong
        toastr.error()
        MnoErrorsHandler.processServerError()
        $q.reject(error)
    )

  return @
