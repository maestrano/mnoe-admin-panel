# Service for managing the comments and reviews.
@App.service 'MnoeReviews', (MnoeAdminApiSvc, MnoeApiSvc, $log, toastr) ->
  _self = @

  # GET List /mnoe/jpi/v1/admin/app_feedbacks
  @listFeedbacks = () ->
    MnoeAdminApiSvc.all('app_feedbacks').getList().then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while fetching reviews', error)
        toastr.error('mnoe_admin_panel.dashboard.reviews_list.toastr_error')
    )

  # GET List /mnoe/jpi/v1/admin/app_questions
  @listQuestions = () ->
    MnoeAdminApiSvc.all('app_questions').getList().then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while fetching questions', error)
        toastr.error('mnoe_admin_panel.dashboard.questions_list.toastr_error')
    )

  # UPDATE /mnoe/jpi/v1/admin/app_reviews/1
  @updateRating = (review) ->
    promise = MnoeAdminApiSvc.one('app_reviews', review.id).patch({status: review.status}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('mnoe_admin_panel.dashboard.feedback.toastr_error')
    )

  @updateDescription = (review) ->
    promise = MnoeAdminApiSvc.one('app_reviews', review.id).patch({description: review.description}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('mnoe_admin_panel.dashboard.feedback.toastr_error')
    )

  @replyQuestion = (id, replyText) ->
    promise = MnoeAdminApiSvc.all("/app_answers").post({question_id: id, app_answer: {description: replyText}}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('mnoe_admin_panel.dashboard.questions_reply_modal.toastr_error')
    )

  @replyFeedback = (id, replyText) ->
    promise = MnoeAdminApiSvc.all("/app_comments").post({feedback_id: id, app_comment: {description: replyText}}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('mnoe_admin_panel.dashboard.comment_edit.toastr_error')
    )

  return @
