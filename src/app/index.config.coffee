@App
  .config(($logProvider, toastrConfig) ->
    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.timeOut = 3000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = true
    toastrConfig.progressBar = true
  )
  .config(($httpProvider) ->
    $httpProvider.interceptors.push(($q, $window, $injector, $log) ->
      return {
        responseError: (rejection) ->
          # Inject the toastr  service (avoid circular dependency)
          toastr = $injector.get('toastr')

          switch rejection.status
            # Unauthenticated
            when 401
              # Redirect the user to the dashboard or login screen
              $window.location.href = "/"

              # Display an error
              toastr.error("You are no longer connected or not an administrator, you will be redirected to the dashboard.")
              $log.error("User is not connected!")

            # Password expired
            when 403
              if rejection.data.error && rejection.data.error == "Your password is expired. Please renew your password."
                $log.info('[PasswordExpiredInterceptor] Password Expired!')
                $window.location.href = "/mnoe/auth/users/password_expired"
                # return an empty promise to skip all chaining promises
                return $q.defer().promise
              else
                return $q.reject(rejection)

            # Redirect to an error page when MnoHub is not available
            when 429, 503
              toastr.error(
                "mnoe_admin_panel.errors.#{rejection.status}.description",
                "mnoe_admin_panel.errors.#{rejection.status}.title"
              )

              $log.info('[MnoHubErrorInterceptor] MnoHub error, redirecting to error page')
              $window.location.href = "/mnoe/errors/#{rejection.status}"
              return $q.defer().promise

            else
              $q.reject rejection
      }
    )
  )

  .config(($translateProvider, LOCALES) ->
    # Path to translations files
    $translateProvider.useStaticFilesLoader(
      files: [
        {
          prefix: 'locales/',
          suffix: '.json'
        },
        {
          prefix: 'locales/impac/',
          suffix: '.json'
        }
      ]
    )

    # language strategy
    $translateProvider.preferredLanguage(LOCALES.preferredLanguage)
    $translateProvider.fallbackLanguage(LOCALES.fallbackLanguage)
    $translateProvider.useMissingTranslationHandlerLog()
    $translateProvider.useSanitizeValueStrategy('sanitize')
    $translateProvider.useMessageFormatInterpolation()

    # remember language
    # $translateProvider.useLocalStorage()
  )

  # Overwrite default template for i18n purpose
  .config(($breadcrumbProvider) ->
    $breadcrumbProvider.setOptions({
      template: '''
        <ol class="breadcrumb">
          <li ng-repeat="step in steps" ng-class="{active: $last}" ng-switch="$last || !!step.abstract">
            <a ng-switch-when="false" href="{{step.ncyBreadcrumbLink}}">{{step.ncyBreadcrumbLabel | translate}}</a>
          <span ng-switch-when="true">{{step.ncyBreadcrumbLabel | translate}}</span>
          </li>
        </ol>
    '''
    })
  )
