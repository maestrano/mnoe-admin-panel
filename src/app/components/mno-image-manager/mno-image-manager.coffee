#
# Image Manager
#
# Upload an image, display the list of image, can reorder and delete
#
@App.component('mnoImageManager', {
  bindings: {
    assets: '<',
    uploadUri: '<',
    fieldName: '<',
    deleteCb: '=',
    isDisabled: '<'
  },
  template: '''
    <form name="vm.imageForm" class="form" novalidate>
      <mno-image-selector ng-model="$ctrl.image"
                          is-disabled="$ctrl.isDisabled"
                          max-size="'5MB'">
      </mno-image-selector>
    </form>

    <button class="btn btn-primary top-buffer-1"
            ng-if="$ctrl.image"
            ng-disabled="!$ctrl.image || $ctrl.isDisabled"
            ng-click="$ctrl.uploadImage($ctrl.image)" translate>
      Submit
    </button>

    <!-- TODO: implement sortable -->
    <ul ui-sortable="$ctrl.sortableOptions" ng-model="$ctrl.assets" class="assets-list top-buffer-1 not-sortable">
      <li class="asset" ng-repeat="asset in $ctrl.assets" ng-class="{'not-sortable': $ctrl.isDisabled}">
        <span class="asset-close" ng-click="$ctrl.deleteImage(asset)" ng-show="!$ctrl.isDisabled">
          <i class="fa fa-close"></i>
        </span>
        <img ng-src="{{asset.url}}" class="img-thumbnail">
      </li>
    </ul>
  ''',
  controller: ($timeout, orderByFilter, Upload, MnoErrorsHandler) ->
    ctrl = this

    ctrl.$onInit = () ->
      ctrl.assets = orderByFilter(ctrl.assets, 'position')

    ctrl.sortableOptions =
      cancel: ".not-sortable"
      stop: (e, ui) ->
        for index of ctrl.assets
          asset = ctrl.assets[index]
          index = parseInt(index)
          # Only save position if it has changed
          if asset.attributes.position != index
            asset.attributes.position = index
            asset.patch(position: index)

    ctrl.uploadImage = () ->
      uploadPromise = Upload.upload(
        url: ctrl.uploadUri
        data:
          field_name: ctrl.fieldName
          content: ctrl.image
      )
      uploadPromise.then(
        (response) ->
          console.log("### DEBUG response", response)
          # Add the new image to the list
          ctrl.assets.push(response.data)
          $timeout ->
            ctrl.image.result = true
        (error) ->
          MnoErrorsHandler.processServerError(error)
          if error.status > 0
            ctrl.image.error = true
        (evt) ->
          ctrl.image.progress = parseInt(100.0 * evt.loaded / evt.total)
      ).finally(
        ->
          $timeout ->
            ctrl.image = null
          , 1000
      )

    ctrl.deleteImage = (image) ->
      ctrl.deleteCb(image).then(
        ->
          _.remove(ctrl.assets, image)
      )

    return
})
