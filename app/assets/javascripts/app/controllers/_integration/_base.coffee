class App.ControllerIntegrationBase extends App.Controller
  events:
    'click .js-submit': 'submit'
    'submit .js-form': 'submit'
    'change .js-switch input': 'switch'

  featureIntegration: 'tbd_integration'
  featureName: 'Tbd'
  #featureConfig: 'tbd_config'
  #featureArea: 'tbd::Config'
  #description:

  constructor: ->
    super

    return if !@authenticate(false, 'Admin')
    @title @featureName, true

    @subscribeId = App.Setting.subscribe(@render, initFetch: true, clear: false)

  switch: =>
    value = @$('.js-switch input').prop('checked')
    App.Setting.set(@featureIntegration, value)

  render: =>
    localEl = $( App.view('integration/base')(
      header: @featureName
      description: @description
      feature: @featureIntegration
      featureEnabled: App.Setting.get(@featureIntegration)
    ))
    @form localEl
    @html localEl

  form: (localEl) ->
    console.log('implement own form method')

  submit: (e) =>
    e.preventDefault()

    params = @formParam(e.target)

    if @featureArea
      count = 0
      for name, value of params
        if App.Setting.findByAttribute('name', name)
          count += 1
          App.Setting.set(
            name,
            value,
            done: ->
              count -= 1
              if count == 0
                App.Event.trigger 'notify', {
                  type:    'success'
                  msg:     App.i18n.translateContent('Update successful!')
                  timeout: 2000
                }
                if @preferences
                  if @preferences.render
                    App.Event.trigger( 'ui:rerender' )

                  if @preferences.session_check
                    App.Auth.loginCheck()

            fail: (settings, details) ->
              App.Event.trigger 'notify', {
                type:    'error'
                msg:     App.i18n.translateContent(details.error_human || details.error || 'Unable to update object!')
                timeout: 2000
              }
          )
      return

    value =
      items: [params]
    App.Setting.set(
      @featureConfig,
      value,
      done: ->
        App.Event.trigger 'notify', {
          type:    'success'
          msg:     App.i18n.translateContent('Update successful!')
          timeout: 2000
        }
        if @preferences
          if @preferences.render
            App.Event.trigger( 'ui:rerender' )

          if @preferences.session_check
            App.Auth.loginCheck()
      fail: (settings, details) ->
        App.Event.trigger 'notify', {
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || 'Unable to update object!')
          timeout: 2000
        }
    )