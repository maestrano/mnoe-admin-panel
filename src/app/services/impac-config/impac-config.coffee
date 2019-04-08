@App.service 'ImpacConfigSvc' , ($state, $stateParams, $log, $q, MnoeAdminConfig, MnoeCurrentUser, MnoeOrganizations, ImpacMainSvc, ImpacRoutes, ImpacTheming, IMPAC_CONFIG) ->
  _self = @

  # Keep track of dashboard designer mode
  _self.dashboardDesigner = null

  # Used to control Impac Angular UI in staff dashboard mode
  # We want to remove the delete dashboard button as this is managed through
  # the staff-dashboard-list component.
  defaultACL = {
    self: {show: true, update: true, destroy: true},
    related: {
      impac: {show: true},
      dashboards: {show: true, create: true, update: true, destroy: false},
      widgets: {show: true, create: true, update: true, destroy: true},
      kpis: {show: false, create: false, update: false, destroy: false}
    }
  }

  # Used to cache temporarily the getOrganizations promise
  _self.orgPromises = {}
  
  @getUserData = ->
    MnoeCurrentUser.getUser()

  @getOrganizations = ->
    if _self.dashboardDesigner
      MnoeCurrentUser.getUser().then(
        (user) ->
          userOrgs = user.organizations
          if _.isEmpty(userOrgs)
            $log.error(err = { message: "Unable to retrieve user organizations" })
            $q.reject(err)
          else
            firstOrgId = userOrgs[0].id
            $q.resolve({ organizations: userOrgs, currentOrgId: firstOrgId })
      )
    else if $stateParams.orgId
      # Staff dashboard mode, returns the current organization
      # Temporary cache the promise and clear the cache when resolved
      # This avoid multiple call to @getOrganizations generating multiple promises in parallel (and API calls)
      # We clear the cache at resolution so we don't have stall data and that's enough to avoid extra API query
      _self.orgPromises[parseInt($stateParams.orgId)] ||= MnoeCurrentUser.getUser().then( ->
        params = if MnoeAdminConfig.isAccountManagerEnabled()
          {sub_tenant_id: MnoeCurrentUser.user.mnoe_sub_tenant_id, account_manager_id: MnoeCurrentUser.user.id}
        else
          {}

        # TODO: problem with pagination (only returns first 30 orgs)
        # Would need rework of the create-dashboard modal in impac-angular
        MnoeOrganizations.list(30, 0, 'name', params).then(
          (response) ->
            organizations = (angular.extend(org, {acl: defaultACL}) for org in response.data)
            _self.orgPromises[parseInt($stateParams.orgId)] = null
            $q.resolve(
              organizations: organizations,
              currentOrgId: parseInt($stateParams.orgId)
            )
        )
      )
    else
      $log.warn('ImpacConfigSvc.getOrganizations: Designer disabled and orgId specified')
      $log.error(err = { message: "Unable to retrieve user organizations" })
      $q.reject(err)

  @configureDashboardDesigner = (enabled) ->
    _self.dashboardDesigner = enabled

    $log.info('Configuring dashboard designer', enabled, _self.dashboardDesigner)

    # Reconfigure Impac routes to use templates or dashboards
    mnoHub = IMPAC_CONFIG.paths.mnohub_api

    if _self.dashboardDesigner
      data =
        dashboards:
          index: "#{mnoHub}/admin/impac/dashboard_templates"
          show: "#{mnoHub}/admin/impac/dashboard_templates/:id"
    else
      data =
        dashboards:
          index: "#{mnoHub}/admin/impac/dashboards"
          show: "#{mnoHub}/admin/impac/dashboards/:id"
          create: "#{mnoHub}/admin/impac/dashboards"

    ImpacRoutes.configureRoutes(data)

    # Configure Dashboard Designer
    options =
      dhbConfig:
        designerMode:
          enabled: enabled
      # For now do not allow to create templates from templates
      dhbSettings:
        createFromTemplateEnabled: !enabled
      # Disable PDF mode in designer mode
      dhbSelectorConfig:
        pdfModeEnabled: !enabled

    ImpacTheming.configure(options)

  @enableDashboardDesigner = ->
    _self.configureDashboardDesigner(true)

  @disableDashboardDesigner = ->
    _self.configureDashboardDesigner(false)

  return
