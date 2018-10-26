# This service is used to manage the configuration of $translate and momentjs.
# Locale strategy in order: URL, user settings, webstore default language, fallback locale.
@App.service('LocaleConfigSvc', ($q, $window, $translate, amMoment, moment, MnoeCurrentUser, LOCALES, URI) ->

  # TODO: do we want to edit the URL when getting the language from the user?
  @configure = ->
    $q.all(url: localeFromUrl(), user: localeFromUser()).then(
      (response) ->
        if l = response.url || response.user
          setLocale(l)
        else
          setFallbackStack(LOCALES.preferred_locale)
    )

  setLocale = (locale) ->
    setFallbackStack(locale)
    $translate.use(locale)
    amMoment.changeLocale(locale)

    # api_root = "/#{locale}#{URI.api_root}"
    # MnoeApiSvc.setBaseUrl(api_root)
    # MnoeFullApiSvc.setBaseUrl(api_root)

  # Check if the detected locale is available
  filterAvailableLocales = (locale) ->
    return unless locale
    _.get(_.find(LOCALES.locales, (l) -> locale == l.id ), 'id')

  # Try to determine the locale from the URL
  localeFromUrl = ->
    # Get current path (eg. "/en/dashboard/" or "/dashboard/")
    path = $window.location.pathname

    # Extract the language code if present
    re = /^\/([A-Za-z]{2}(-[A-Z]{2})?)\/dashboard\//i
    found = path.match(re)

    # Ex found: ["/en/dashboard/", "en", index: 0, input: "/en/dashboard/"]
    locale = filterAvailableLocales(found[1]) if found?

    $q.resolve(locale)

  # Find the locale from the User#settings
  localeFromUser = ->
    MnoeCurrentUser.getUser().then(
      (response) ->
        filterAvailableLocales(response.settings?.locale)
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

  return @
)
