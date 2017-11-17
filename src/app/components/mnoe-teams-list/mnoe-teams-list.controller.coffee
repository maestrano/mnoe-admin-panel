#
# Mnoe teams List
#
@App.component('mnoeTeamsList', {
  templateUrl: 'app/components/mnoe-teams-list/mnoe-teams-list.html',
  bindings: {
    organization: '<'
  }

  controller: (MnoeTeams) ->
    ctrl = this

    teamToggled = {}
    ctrl.isTeamsLoading = true
    ctrl.teams =
      list:[]
      search: ""
      sort: "name"
      nbItems: 10
      offset: 0
      page: 1
      pageChangedCb: (nbItems, page) ->
        ctrl.teams.nbItems = nbItems
        ctrl.teams.page = page
        offset = (page  - 1) * nbItems
        fetchTeams(nbItems, offset)

    ctrl.$onChanges = (changes) ->
      # Call the server when ready
      fetchTeams(ctrl.teams.nbItems, ctrl.teams.offset, ctrl.teams.sort) if changes.organization && !_.isEmpty(ctrl.organization)

    ctrl.hasApps = (apps) ->
      apps.length > 0

    ctrl.hasUsers = (users) ->
      users.length > 0

    ctrl.toggleTeam = (teamToExpand) ->
      if teamToggled.id == teamToExpand.id
        teamToggled.expanded = !teamToggled.expanded
      else
        teamToggled.expanded = false
        teamToggled = _.find(ctrl.teams.list, (team) -> team.id == teamToExpand.id)
        teamToggled.expanded = true

    fetchTeams = (limit, offset, sort = ctrl.teams.sort) ->
      ctrl.isTeamsLoading = true    
      MnoeTeams.list(ctrl.organization.id, limit, offset, sort).then(
        (response) ->
          ctrl.teams.list = response.data
          ctrl.teams.totalItems = response.headers('x-total-count')
          ctrl.isTeamsLoading = false
        )

    return
})
