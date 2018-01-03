@App.controller 'BatchUploadController', ($window, $injector, MnoeCurrentUser) ->
  'ngInject'
  vm = this

  MnoeCurrentUser.getUser().then( ->
    vm.user = MnoeCurrentUser.user
    if !vm.user.id?
      toastr = $injector.get('toastr')
      $window.location.href = "/"
      toastr.error("You are no longer connected or not an administrator, you will be redirected to the dashboard.")
      $log.error("User is not connected!")
  )

  vm.downloadExample = ->
    $window.open('/mnoe/jpi/v1/admin/organizations/download_batch_example', '_blank')

  vm.onUploadStart= ->
    vm.errors = null
    vm.report = null

  vm.onUploadSuccess = (result)->
    vm.report = result.data

  vm.onUploadError = (error)->
    vm.errors = error.data

  return
