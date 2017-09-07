# Service for managing the Audit Log.
@App.service 'MnoeDashboardTemplates', (MnoeAdminApiSvc, ImpacDashboardsSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    MnoeAdminApiSvc.all("/impac/dashboard_templates").getList({order_by: sort, limit: limit, offset: offset})

  @templates = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("/impac/dashboard_templates").getList(params)

  @delete = (dashboardTemplateId) ->
    MnoeAdminApiSvc.one("/impac/dashboard_templates", dashboardTemplateId).remove()

  @search = (terms) ->
    MnoeAdminApiSvc.all("/impac/dashboard_templates").getList({terms: terms})

  togglePublished = (templateId) ->
    template = _.find(ImpacDashboardsSvc.getDashboards(), (dhb) ->
      dhb.id == templateId
    )
    return unless template?
    ImpacDashboardsSvc.update(templateId, { published: !template.published })

  @toggleTemplatePublished = (templateId) ->
    return togglePublished(templateId) unless angular.isDefined(ImpacDashboardsSvc.getDashboards())
    ImpacDashboardsSvc.load().then( -> togglePublished(templateId))

  return @

