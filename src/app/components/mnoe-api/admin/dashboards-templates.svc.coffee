# Service for managing the Audit Log.
@App.service 'MnoeDashboardTemplates', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all("/dashboard_templates").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        response
    )

  @templates = (limit, offset, sort, params = {}) ->
    return _getTemplates(limit, offset, sort, params)

  @delete = (dashboardTemplateId) ->
    promise = MnoeAdminApiSvc.one("dashboard_templates", dashboardTemplateId).remove().then(
      (response) ->
        response
    )

  @search = (terms) ->
    MnoeAdminApiSvc.all("/dashboard_templates").getList({terms: terms})

  @update = (dashboardTemplate) ->
    promise = MnoeAdminApiSvc.one("dashboard_templates", dashboardTemplate.id).patch(dashboardTemplate).then(
      (response) ->
        response
      )

  _getTemplates = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("/dashboard_templates").getList(params)

  return @

