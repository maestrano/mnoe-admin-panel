@App.controller 'ProvisioningLayoutController', ($scope, $location) ->

  # Used for the provisioning workflow If we are changing/creating a new order we want the edit plan breacrumb, otherwise not.
  $scope.showOrder = () ->
    $location.$$path.includes('provision', 'change')

  $scope.breadcrumbNumber = (number) ->
    if $scope.showOrder()
      number
    else
      number - 1
