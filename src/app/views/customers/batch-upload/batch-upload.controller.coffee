@App.controller 'BatchUploadController', ($timeout, Upload, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.downloadExample = ->
    window.location =  "/mnoe/jpi/v1/admin/organizations/download_batch_example"

  vm.uploadFile = ->
    vm.progressBarType = 'primary'
    vm.isUploading = true
    file = vm.file
    form = vm.form
    vm.errors = null
    vm.addedOrganizations = null
    vm.updatedOrganizations = null
    vm.addedUsers = null
    vm.updatedUsers = null
    file.upload = Upload.upload(
      headers: {'Accept': 'application/json'},
      url: "/mnoe/jpi/v1/admin/organizations/batch_import"
      data:
        file: file
    )
    file.upload.then(
      (result) ->
        vm.addedOrganizations = result.data.added_organizations
        vm.updatedOrganizations = result.data.updated_organizations
        vm.addedUsers = result.data.added_users
        vm.updatedUsers = result.data.updated_users
        # Display upload successful & reset the form
        $timeout ->
          file.result = true
          form.$setPristine()
        # Remove the upload bar after 3000ms
        $timeout((-> file.progress = -1), 3000)
      (error) ->
        MnoErrorsHandler.processServerError(error)
        vm.errors = error.data
        vm.progressBarType = 'danger'
      (evt) ->
        file.progress = parseInt(100.0 * evt.loaded / evt.total)
    ).finally(-> vm.isUploading = false)

  return
