# This directive is able to manage price fields stored as cents
@App.directive 'currencyCentsInput', ->
  return {
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      # Parse the input display (20.12) to the ngModel value (2012)
      ngModel.$parsers.push((value) ->
        return parseInt(value * 100)
      )
      # Format the ngModel value (eg. 2012) to the input display (20.12)
      ngModel.$formatters.push((value) ->
        return value / 100
      )
  }
