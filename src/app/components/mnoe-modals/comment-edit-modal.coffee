angular.module 'frontendAdmin'
.controller('CommentEditModal', ($scope, $uibModalInstance, review) ->

  $scope.review = review

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    $uibModalInstance.close(review)

  return
)
