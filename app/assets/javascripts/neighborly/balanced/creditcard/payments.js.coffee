Neighborly.Neighborly                              ?= {}
Neighborly.Neighborly.Balanced                     ?= {}
Neighborly.Neighborly.Balanced.Creditcard          ?= {}
Neighborly.Neighborly.Balanced.Creditcard.Payments ?= {}

Neighborly.Neighborly.Balanced.Creditcard.Payments.New = Backbone.View.extend
  el: '.neighborly-balanced-creditcard-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')

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

  submit: (e)=>
    e.preventDefault()

