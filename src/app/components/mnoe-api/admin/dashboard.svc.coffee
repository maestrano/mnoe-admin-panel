# Service for managing staff dashboards
@App.service 'MnoeDashboards', (MnoeAdminApiSvc, MnoeCurrentUser) ->
  _self = @

  # List the staff dashboard for the current user
  @getStaffDashboards = (organizationUid, limit, offset, sort) ->
    MnoeAdminApiSvc.all("/impac/dashboards").getList({
      order_by: sort,
      limit: limit,
      offset: offset,
      'where[data_sources]': [organizationUid]
    })

  # Delete a dashboard
  @delete = (dashboardId) ->
    MnoeAdminApiSvc.one("/impac/dashboards", dashboardId).remove()

  return @
