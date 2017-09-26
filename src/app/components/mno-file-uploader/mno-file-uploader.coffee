#
# File Uploader
#
# Upload an a file
#
@App.component('mnoFileUploader', {
  bindings: {
    maxSize: '@',
    uploadUri: '@',
    fileTypes: '@',
    startCallback: '&',
    successCallback: '&',
    errorCallback: '&'
  },
  template: '''
    <form name="$ctrl.form" novalidate>
      <fieldset>
        <input type="file" accept="{{$ctrl.fileTypes}}" ngf-select ng-model="$ctrl.file" name="file" ngf-max-size="{{$ctrl.maxSize}}" required ngf-model-invalid="errorFile">
        <i ng-show="$ctrl.form.file.$error.maxSize"><span translate>mnoe_admin_panel.components.mno-file-uploader.file_too_large</span> : {{errorFile.size / 1000000|number:1}}MB, max {{$ctrl.maxSize}}</i>
        <div class="top-buffer-1">
          <button type="button" class="btn btn-primary" ng-disabled="!$ctrl.form.$valid || $ctrl.isUploading" ng-click="$ctrl.uploadFile()" translate>
            mnoe_admin_panel.components.mno-file-uploader.submit
          </button>
          <span ng-show="$ctrl.isUploading"><i class="fa fa-spinner fa-pulse fa-fw"></i>&nbsp;</span>
        </div>
      </fieldset>
      <div class="progress top-buffer-1" ng-show="$ctrl.file.progress >= 0">
        <uib-progressbar value="$ctrl.file.progress" type="{{$ctrl.progressBarType}}">
          <span ng-show="$ctrl.errors" translate>mnoe_admin_panel.components.mno-file-uploader.upload_failed</span>
          <span ng-show="$ctrl.file.result" translate>mnoe_admin_panel.components.mno-file-uploader.upload_successful</span>
          <span ng-show="!$ctrl.file.result && !$ctrl.errors">{{$ctrl.file.progress}}%</span>
        </uib-progressbar>
      </div>
    </form>
  ''',
  controller: ($timeout, Upload, MnoErrorsHandler) ->
    ctrl = this

    ctrl.uploadFile = ->
      ctrl.startCallback()
      ctrl.progressBarType = 'primary'
      ctrl.isUploading = true
      file = ctrl.file
      form = ctrl.form
      ctrl.hasErrors = false
      file.upload = Upload.upload(
        headers: {'Accept': 'application/json'},
        url: ctrl.uploadUri
        data:
          file: file
      )
      file.upload.then(
        (result) ->
          # Display upload successful & reset the form
          $timeout ->
            file.result = true
            form.$setPristine()
          # Remove the upload bar after 3000ms
          $timeout((-> file.progress = -1), 3000)
          ctrl.successCallback({value: result})
        (error) ->
          MnoErrorsHandler.processServerError(error)
          ctrl.hasErrors = true
          ctrl.errorCallback({value: error})
          ctrl.progressBarType = 'danger'
        (evt) ->
          file.progress = parseInt(100.0 * evt.loaded / evt.total)
      ).finally(-> ctrl.isUploading = false)


    return
})
