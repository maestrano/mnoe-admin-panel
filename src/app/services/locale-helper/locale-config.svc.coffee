# This service is used to manage the configuration of $translate and momentjs.
# Locale strategy in order: URL, user settings, webstore default language, fallback locale.
@App.service('LocaleConfigSvc', ($q, $window, $translate, amMoment, moment, MnoeCurrentUser, MnoeTenant, LOCALES, URI) ->

  @configure = ->
    $q.all(url: localeFromUrl(), user: localeFromUser(), tenant: localeFromTenant()).then(
      (response) ->
        # Order of array represents order in which locales will be chosen.
        locales = [response.url, response.user, response.tenant]
        # Uncomment to enable il8n locales.
        # setIl8nLocales(locales)
        setAmLocales(locales)
    )

  setIl8nLocales = (locales) ->
    # Find the first available locale and use it, otherwise use the preferred_locale
    il8nAvailableLocales = locales.map((l) -> filterAvailableLocales(l))
    firstAvailLocale = il8nAvailableLocales.find((l) -> !!l)
    if firstAvailLocale
      setFallbackStack(firstAvailLocale)
      $translate.use(firstAvailLocale)
    else
      setFallbackStack(LOCALES.preferred_locale)

  setAmLocales = (locales) ->
    # No need to filter on available locales, as amMoment automatically loads locales.
    amMoment.changeLocale(locales.find((l) -> !!l))

  # Check if the detected locale is available
  filterAvailableLocales = (locale) ->
    return unless locale
    _.get(_.find(LOCALES.locales, (l) -> locale == l.id ), 'id')

  # Find the locale from the User#settings
  localeFromUser = ->
    MnoeCurrentUser.getUser().then((response) ->
      response.settings?.locale
    )

  # Find the locale from the Tenant#settings
  localeFromTenant = ->
    MnoeTenant.get().then((response) ->
      response.data?.frontend_config?.system?.i18n?.preferred_locale
    )

  # Build our fallback stack manually to be ['language', preferredLanguage, LOCALES.fallbackLanguage]
  # eg: If the detected locale is 'fr-FR' and the preferred language 'en-GB', the fallback stack is
  # ['fr', 'en-GB', 'en']
  # This is similar to the angular-translate implementation except they push th preferredLanguage at the end
  setFallbackStack = (locale)->
    fallbackStack = []
    if locale?.length == 5
      language = locale.slice(0,2)

      # Start with the language code
      fallbackStack.push(language)

    # Then the preferred language
    prefLanguage = $translate.preferredLanguage()

    if (angular.isString(prefLanguage) && prefLanguage not in fallbackStack)
      fallbackStack.push(prefLanguage)

    # Then the framework default ('en')
    if (angular.isString(LOCALES.fallbackLanguage) && LOCALES.fallbackLanguage not in fallbackStack)
      fallbackStack.push(LOCALES.fallbackLanguage)

    amMoment.changeLocale(fallbackStack[0])
    $translate.fallbackLanguage(fallbackStack)

  localeFromUrl = ->
    false
    # TODO: Uncomment to setup URL locale detection.
    #   # Get current path (eg. "/en/admin/" or "/admin/")
    #   path = $window.location.pathname
    #
    #   # Extract the language code if present
    #   re = /^\/([A-Za-z]{2}(-[A-Z]{2})?)\/dashboard\//i
    #   found = path.match(re)
    #
    #   # Ex found: ["/en/dashboard/", "en", index: 0, input: "/en/dashboard/"]
    #   locale = found[1]) if found?
    #
    #   $q.resolve(locale)

  return @
)
