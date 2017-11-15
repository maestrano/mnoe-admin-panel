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

    ctrl.$onChanges = (changes) ->
      # Call the server when ready
      fetchTeams() if changes.organization && !_.isEmpty(ctrl.organization)
      
    fetchTeams = () ->
      MnoeTeams.list(ctrl.organization.id).then(
        (response) ->
          ctrl.teams = response.data.plain()
          ctrl.teams.totalItems = response.headers('x-total-count')
        )

    return
})
