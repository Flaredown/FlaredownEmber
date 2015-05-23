`import Ember from 'ember'`

mixin = Ember.Mixin.create

  keenPageviewEvent: ->
    if typeof(window.keen) isnt "undefined"
      #Configure the jQuery cookie plugin to use JSON.
      $.cookie.json = true

      #Set the amount of time a session should last.
      sessionExpireTime = new Date
      sessionExpireTime.setMinutes sessionExpireTime.getMinutes() + 30

      #Check if we have a session cookie:
      session_cookie = $.cookie('session_cookie')
      #If it is undefined, set a new one.
      if session_cookie == undefined
        $.cookie 'session_cookie', { id: UUIDjs.create().toString() },
          expires: sessionExpireTime
          path: '/'
      else
        $.removeCookie 'session_cookie', path: '/'
        $.cookie 'session_cookie', session_cookie,
          expires: sessionExpireTime
          path: '/'
      permanent_cookie = $.cookie('permanent_cookie')
      #If it is undefined, set a new one.
      if permanent_cookie == undefined
        $.cookie 'permanent_cookie', { id: UUIDjs.create().toString() },
          expires: 3650
          path: '/'

      #Add a pageview event in Keen IO
      fullUrl = window.location.href
      parsedUrl = $.url(fullUrl)
      parser = new UAParser
      eventProperties =
        session_id: $.cookie('session_cookie')['id']
        url:
          source: parsedUrl.attr('source')
          protocol: parsedUrl.attr('protocol')
          domain: parsedUrl.attr('host')
          port: parsedUrl.attr('port')
          path: parsedUrl.attr('path')
          anchor: parsedUrl.attr('anchor')
        user_agent:
          browser: parser.getBrowser()
          engine: parser.getEngine()
          os: parser.getOS()
        permanent_tracker: $.cookie('permanent_cookie')['id']

      # If you know that the user is currently logged in, add information about the user.
      if window.user_id
        eventProperties["user"] = {
          id: window.user_id
          current_location: window.current_location
        }

      #Add information about the referrer of the same format as the current page
      referrer = document.referrer
      referrerObject = null
      if referrer != undefined
        parsedReferrer = $.url(referrer)
        referrerObject =
          source: parsedReferrer.attr('source')
          protocol: parsedReferrer.attr('protocol')
          domain: parsedReferrer.attr('host')
          port: parsedReferrer.attr('port')
          path: parsedReferrer.attr('path')
          anchor: parsedReferrer.attr('anchor')

      eventProperties['referrer'] = referrerObject

      keen.addEvent 'pageviews', eventProperties

`export default mixin`