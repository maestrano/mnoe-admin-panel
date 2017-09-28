@App.controller 'BatchUploadController', ($window) ->
  'ngInject'
  vm = this

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
