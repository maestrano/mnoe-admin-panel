@App.controller 'BatchUploadController', ($window, toastr, URI, MnoeCurrentUser) ->
  'ngInject'
  vm = this

  MnoeCurrentUser.getUser().then( ->
    user = MnoeCurrentUser.user
    if !user.id?
      redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
      $window.location.href = URI.login + "?return_to=#{redirect}"
      toastr.error("mnoe_admin_panel.errors.401.description")
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
