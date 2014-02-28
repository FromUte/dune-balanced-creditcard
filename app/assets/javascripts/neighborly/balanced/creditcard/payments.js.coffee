Neighborly.Neighborly                              ?= {}
Neighborly.Neighborly.Balanced                     ?= {}
Neighborly.Neighborly.Balanced.Creditcard          ?= {}
Neighborly.Neighborly.Balanced.Creditcard.Payments ?= {}

Neighborly.Neighborly.Balanced.Creditcard.Payments.New = Backbone.View.extend
  el: '.neighborly-balanced-creditcard-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')

    $.getScript 'https://js.balancedpayments.com/v1/balanced.js', ->
      balancedMarketplaceID = $('[data-balanced-credit-card-form]').attr('data-balanced-marketplace-id')
      balanced.init("/v1/marketplaces/#{balancedMarketplaceID}")

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form')
    this.$form.bind('submit', this.submit)
    this.$('input[type=radio]').bind('change', this.toggleAddNewCard)

  validate: =>

  toggleAddNewCard: =>
    this.$('.radio.checked').removeClass('checked')
    this.$('input[type=radio]:checked ~ .radio').addClass('checked')
    if this.$('#payment_use_card_new').is(':checked')
      this.$('.add-new-creditcard-form').removeClass('hide')
    else
      this.$('.add-new-creditcard-form').addClass('hide')

  submit: (event) =>
    selectedCard = this.$('[name="payment[use_card]"]:checked, [name="payment[use_card]"]:hidden')
    return if $.inArray(selectedCard.val(), ['new', '']) == -1

    event.preventDefault()

    creditCardData =
      card_number:      this.$('#payment_card_number').val()
      expiration_month: this.$('#payment_expiration_month').val()
      expiration_year:  this.$('#payment_expiration_year').val()
      security_code:    this.$('#payment_security_code').val()
    this.$('[data-balanced-credit-card-input]').val('')

    balanced_callback_for_201 = (response) ->
      selectedCard.val(response.data.uri)
      $('[data-balanced-credit-card-form] form').submit()

    balanced_callback_for_402 = (response) ->
      alertBox     = $('<div>', { 'class': 'row', 'html':
                       $('<div>', { 'class': 'alert-box large-10 columns large-centered animated fadeIn alert dismissible', 'html':  'The card submitted is invalid.' })
                     } )
      flashWrapper = $('.flash') || $('body > header').next($('<div>', { 'class': 'flash', 'html' }))
      flashWrapper.append(alertBox)
      $('.neighborly-balanced-creditcard-form [type="submit"').
        removeAttr('disabled').
        remoreAttr('data-disable-with').
        attr('value', 'Confirm payment')

    balanced.card.create creditCardData, (response) ->
      switch response.status
        when 201 then balanced_callback_for_201(response)
        when 402 then balanced_callback_for_402(response)
