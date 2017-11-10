@App.service 'MnoeNotifications', ($q, $translate, MnoeAdminApiSvc) ->
  @get = (params = {}) ->
    deferred = $q.defer()
    MnoeAdminApiSvc.all('notifications').getList(params).then((response) ->
      promises = _.map(response.data.plain(), (notification)->
        NotificationFormatter[notification.notification_type](notification)
      )
      $q.all(promises).then(deferred.resolve)
    )
    deferred.promise

  @notified = (params)->
    MnoeAdminApiSvc.one('notifications').post('/notified', params)

  formatDate = (date)->
    moment(date).format('LL')

  isToday = (date)->
    moment(date).isSame(moment(), 'd')

  NotificationFormatter = {}

  NotificationFormatter.reminder = (notification) ->
    task = notification.task
    deferred = $q.defer()
    $translate([
        'mnoe_admin_panel.notifications.reminder.title',
        'mnoe_admin_panel.notifications.reminder.message.title',
        'mnoe_admin_panel.notifications.reminder.message.from',
        'mnoe_admin_panel.notifications.reminder.message.due',
        'mnoe_admin_panel.notifications.reminder.message.details'
      ],
      {
        user_name: task.owner.user.name
        user_surname: task.owner.user.surname,
        organization_name: task.owner.organization.name,
        due_date: formatDate(task.due_date)
      }
    ).then((tls)->
      message = [
        tls['mnoe_admin_panel.notifications.reminder.message.title'],
        tls['mnoe_admin_panel.notifications.reminder.message.from'],
        tls['mnoe_admin_panel.notifications.reminder.message.due'],
        tls['mnoe_admin_panel.notifications.reminder.message.details']
      ].join('</br>')

      deferred.resolve({
        object_id: notification.object_id,
        object_type: notification.object_type,
        notification_type: notification.notification_type,
        method: 'info',
        title: tls['mnoe_admin_panel.notifications.reminder.title'],
        message: message,
      })
    )
    deferred.promise

  NotificationFormatter.due = (notification) ->
    task = notification.task
    deferred = $q.defer()
    $translate([
        'mnoe_admin_panel.notifications.due.title',
        'mnoe_admin_panel.notifications.due.title_today',
        'mnoe_admin_panel.notifications.due.message.title',
        'mnoe_admin_panel.notifications.due.message.from',
        'mnoe_admin_panel.notifications.due.message.details'
      ],
      {
        user_name: task.owner.user.name
        user_surname: task.owner.user.surname,
        organization_name: task.owner.organization.name,
        due_date: formatDate(task.due_date),
        task_title: task.title
      }
    ).then((tls)->
      message = [
        tls['mnoe_admin_panel.notifications.due.message.title'],
        tls['mnoe_admin_panel.notifications.due.message.from'],
        tls['mnoe_admin_panel.notifications.due.message.details']
      ].join('</br>')
      title = if isToday(task.due_date)
        tls['mnoe_admin_panel.notifications.due.title_today']
      else
        tls['mnoe_admin_panel.notifications.due.title']
      deferred.resolve({
        object_id: notification.object_id,
        object_type: notification.object_type,
        notification_type: notification.notification_type,
        method: 'warning',
        title: title,
        message: message,
      })
    )
    deferred.promise

  NotificationFormatter.completed = (notification) ->
    task = notification.task
    recipient = task.task_recipients[0]
    deferred = $q.defer()
    $translate([
        'mnoe_admin_panel.notifications.completed.title',
        'mnoe_admin_panel.notifications.completed.message.has_completed',
        'mnoe_admin_panel.notifications.completed.message.details'
      ],
      {
        user_name: recipient.user.name
        user_surname: recipient.user.surname,
        organization_name: recipient.organization.name,
        task_title: task.title
      }
    ).then((tls)->
      message = [
        tls['mnoe_admin_panel.notifications.completed.message.has_completed'],
        tls['mnoe_admin_panel.notifications.completed.message.details']
      ].join('</br>')

      deferred.resolve({
        object_id: notification.object_id,
        object_type: notification.object_type,
        notification_type: notification.notification_type,
        method: 'info',
        title: tls['mnoe_admin_panel.notifications.completed.title'],
        message: message,
      })
    )
    deferred.promise

  return @
