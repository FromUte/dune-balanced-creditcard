Neighborly.Neighborly                              ?= {}
Neighborly.Neighborly.Balanced                     ?= {}
Neighborly.Neighborly.Balanced.Creditcard          ?= {}
Neighborly.Neighborly.Balanced.Creditcard.Payments ?= {}

Neighborly.Neighborly.Balanced.Creditcard.Payments.New = Backbone.View.extend
  el: '.neighborly-balanced-creditcard-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')

    $.getScript 'https://js.balancedpayments.com/v1/balanced.js', ->
      balanced.init('/v1/marketplaces/TEST-MP24PC81sknFKEuhffrbAixq')

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
    selectedCard = this.$('[name="payment[use_card]"]:checked')
    return if selectedCard.val() != 'new'

    event.preventDefault()

    creditCardData =
      card_number:      this.$('#payment_card_number').val()
      expiration_month: this.$('#payment_expiration_month').val()
      expiration_year:  this.$('#payment_expiration_year').val()
      security_code:    this.$('#payment_security_code').val()
    this.$('[data-balanced-credit-card-input]').val('')

    balanced.card.create creditCardData, (response) ->
      selectedCard.val(response.data.uri)
      $('[data-balanced-credit-card-form] form').submit()
