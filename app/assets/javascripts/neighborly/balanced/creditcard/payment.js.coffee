window.NeighborlyBalancedCreditcard = Backbone.View.extend
  el: '.neighborly-balanced-creditcard-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')
    $(document).foundation('forms')

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form')
    this.$form.bind('submit', this.submit)

  validate: ->

  submit: (e)->
    e.preventDefault()

