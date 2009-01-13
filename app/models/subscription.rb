class Subscription < ActiveRecord::Base
  attr_accessor :credit_card
  belongs_to :user
  belongs_to :plan
  
  def initialize(params)
    #super params[:credit_card]
    @credit_card = params[:credit_card]
    #@credit_card[expiration_month] = params[:credit_card_expiration_month]
    #@credit_card[expiration_year] = params[:credit_card_expiration_year]

    raise @credit_card.to_s
  end
  
  #TODO put paypal subscription here
  def subscribe
  end
  
  #TODO put paypal subscription change here
  def upgrade
  end
  
  #TODO put paypal subscription change here
  def downgrade
  end

  #TODO put paypal un-subscription here
  def cancel
  end
end
