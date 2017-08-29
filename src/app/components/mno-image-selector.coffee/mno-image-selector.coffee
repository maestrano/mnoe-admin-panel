#
# Dynamic input
#
@App.component('mnoImageSelector', {
  bindings: {
    maxSize: '<'
    defaultPreview: '@'
    required: '@'
    isDisabled: '='
  },
  require: {
    form: '^form'
    ngModel: 'ngModel'
  },
  transclude: true,
  template: '''
    <input type="file" ngf-select ng-model="$ctrl.file" ng-change="$ctrl.updateParentModel()" name="logoFile"
           ngf-pattern="'image/*,!.svg'" ngf-accept="'image/*'" ngf-max-size="$ctrl.maxSize" ngf-model-invalid="errorFile"
           ng-disabled="$ctrl.isDisabled">
    <div class="top-buffer-1 clearfix">
      <img ng-show="$ctrl.file" ngf-thumbnail="$ctrl.file" class="img-thumbnail pull-left" style="max-width: 200px;">
      <img ng-show="!$ctrl.file && $ctrl.defaultPreview" ng-src="{{$ctrl.defaultPreview}}" class="img-thumbnail pull-left" style="max-width: 200px;">
      <div class="pull-left" style="margin-left: 8px" ng-transclude></div>
    </div>
    <div class="text-danger" ng-if="$ctrl.form.logoFile.$dirty || $ctrl.form.$submitted" ng-messages="$ctrl.form.logoFile.$error">
      <p ng-message="maxSize">
        File too large {{vm.errorFile.size / 1000000|number:1}}MB: max {{$ctrl.maxSize}}
      </p>
      <p ng-message="pattern">
        Authorized formats: jpeg, jpg, gif, png
      </p>
    </div>
    <div class="progress top-buffer-1" ng-show="$ctrl.file.progress >= 0">
      <uib-progressbar value="$ctrl.file.progress">
        <span ng-show="$ctrl.file.result">Upload successful</span>
        <span ng-show="$ctrl.file.error">An error occurred</span>
        <span ng-show="!$ctrl.file.result && !$ctrl.file.error">{{$ctrl.file.progress}}%</span>
      </uib-progressbar>
    </div>
  ''',
  controller: () ->
    ctrl = this

    ctrl.$onInit = () ->
      # $render is called when angular detects a change to the model
      ctrl.ngModel.$render = () ->
        ctrl.file = ctrl.ngModel.$viewValue

    # Update the parent controller binding
    ctrl.updateParentModel = () ->
      ctrl.ngModel.$setViewValue(ctrl.file)

    return
})
