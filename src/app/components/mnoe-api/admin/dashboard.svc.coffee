# Service for managing staff dashboards
@App.service 'MnoeDashboards', (MnoeAdminApiSvc, MnoeCurrentUser) ->
  _self = @

  # List the staff dashboard for the current user
  @getStaffDashboards = (organizationId, limit, offset, sort) ->
    MnoeCurrentUser.getUser().then(
      -> MnoeCurrentUser.user
    ).then(
      (user) ->
        MnoeAdminApiSvc.all("/impac/dashboards").getList({
          order_by: sort,
          limit: limit,
          offset: offset,
          'where[owner_id]': user.id,
          'where[owner_type]': 'User',
          'where[data_sources]': [organizationId]
        })
    )

  # Delete a dashboard
  @delete = (dashboardId) ->
    MnoeAdminApiSvc.one("/impac/dashboards", dashboardId).remove()

  return @
