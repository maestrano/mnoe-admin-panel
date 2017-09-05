# This directive is able to manage percents stored as fractions of 1
angular.module('frontendAdmin').directive 'percentageInput', ->
  return {
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      # Parse the input display (0.152) to the ngModel value (15.2)
      ngModel.$parsers.push((value) ->
        return value / 100
      )
      # Format the ngModel value (eg. 15.2) to the input display (0.152)
      # Math.round hack enables to avoid displaying .00
      ngModel.$formatters.push((value) ->
        return value * 100
      )
  }
