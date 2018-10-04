@App.filter('yesNo', () ->
  (input) ->
    if input then 'mnoe_admin_panel.constants.yes' else 'mnoe_admin_panel.constants.no'
)

@App.filter('notApplicable', () ->
  (input) ->
    if input then input else 'mnoe_admin_panel.constants.not_applicable'
)

@App.filter('capitalize', () ->
  (input) ->
    _.startCase(input.toLowerCase());
)
