@App.directive('mnoeQuestionsList', ($filter, $log, $uibModal, MnoeReviews) ->
  restric:'E'
  scope: {
  }
  templateUrl:'app/components/mnoe-questions-list/mnoe-questions-list.html'
  link: (scope) ->

    scope.editmode = []
    scope.listOfQuestions = []
    scope.statuses = [
      {value: 'approved', label: 'mnoe_admin_panel.dashboard.questions_list.status_label.approved'},
      {value: 'rejected', label: 'mnoe_admin_panel.dashboard.questions_list.status_label.rejected'}]

    #====================================
    # Comment modal
    #====================================
    scope.openCommentModal = () ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/comment-modal.html'
        controller: 'CommentModal'
      )

    scope.openEditModal = (question) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/question-edit-modal.html'
        controller: 'CommentEditModal'
        resolve:
          review: question
      ).result.then(
        (question) ->
          MnoeReviews.updateDescription(question)
      )

    scope.openEditAnswerModal = (answer) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/answer-edit-modal.html'
        controller: 'CommentEditModal'
        resolve:
          review: answer
      ).result.then(
        (answer) ->
          MnoeReviews.updateDescription(answer)
      )

    scope.openQuestionReplyModal = (question) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-modals/question-reply-modal.html'
        controller: 'QuestionReplyModal'
      ).result.then(
        (replyText) ->
          MnoeReviews.replyQuestion(question.id, replyText).then(
            (response) ->
              question.answers.unshift(response.data.app_answer)
          )

      )

    fetchQuestions = () ->
      return MnoeReviews.listQuestions().then(
        (response) ->
          scope.listOfQuestions = response.data
      )

    scope.update = (question) ->
      MnoeReviews.updateRating(question).then(
        (response) ->
          # Remove the edit mode for this question
          delete scope.editmode[question.id]
      )

    fetchQuestions()
    return
)
