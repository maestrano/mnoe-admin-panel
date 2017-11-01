@App.directive('mnoeReviewsList', ($filter, $log, $uibModal, MnoeReviews) ->
  restric:'E'
  scope: {
  }
  templateUrl:'app/components/mnoe-reviews-list/mnoe-reviews-list.html'
  link: (scope) ->

    scope.editmode = []
    scope.listOfReviews = []
    scope.statuses = [
      {value: 'approved', label: 'mnoe_admin_panel.dashboard.reviews_list.status_label.approved'},
      {value: 'rejected', label: 'mnoe_admin_panel.dashboard.reviews_list.status_label.rejected'}]

    #====================================
    # Comment modal
    #====================================
    scope.openCommentModal = () ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/comment-modal.html'
        controller: 'CommentModal'
      )

    scope.openEditModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/comment-edit-modal.html'
        controller: 'CommentEditModal'
        resolve:
          review: angular.copy(review)
      ).result.then(
        (review) ->
          MnoeReviews.updateDescription(review).then(
            (success) ->
              reviewEdited = success.data.app_review
              # find the no edited review
              reviewNoEdited = _.find(scope.listOfReviews, {id: reviewEdited.id})
              # update description in dom
              reviewNoEdited.description = reviewEdited.description
            )
      )

    scope.openFeedbackReplyModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/feedback-reply-modal.html'
        controller: 'FeedbackReplyModal'
      ).result.then(
        (replyText) ->
          MnoeReviews.replyFeedback(review.id, replyText).then(
            (response) ->
              review.comments.unshift(response.data.app_comment)
          )
      )

    fetchReviews = () ->
      return MnoeReviews.listFeedbacks().then(
        (response) ->
          scope.listOfReviews = response.data
      )

    scope.update = (review) ->
      MnoeReviews.updateRating(review).then(
        (response) ->
          # Remove the edit mode for this review
          delete scope.editmode[review.id]
      )

    fetchReviews()
    return
)
