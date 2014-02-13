window.NeighborlyBalancedCreditcard = Backbone.View.extend
  el: '.neighborly-balanced-creditcard-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')
    $(document).foundation('forms')

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form')
    this.$form.bind('submit', this.submit)
    this.$('#payment_use_previously_card').bind('change', this.toggleAddNewCard)

  validate: =>

  toggleAddNewCard: =>
    this.$('.add-new-creditcard-form').toggleClass('hide')

  submit: (e)=>
    e.preventDefault()

