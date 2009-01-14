class Subscription < ActiveRecord::Base
  attr_accessor :credit_card
  belongs_to :user
  belongs_to :plan
  
  # def initialize(params)
  #     super(params)
  #     @credit_card = params[:credit_card]
  #   end
  
  #TODO put paypal subscription here
  def subscribe
    credit_card = ActiveMerchant::Billing::CreditCard.new(
        :type       => @credit_card[:type],
        :number     => @credit_card[:number],
        :month      => @credit_card[:month],
        :year       => @credit_card[:year],
        :first_name => @credit_card[:first_name],
        :last_name  => @credit_card[:last_name]
    )
    options = {  
      :email => "#{self.user.email}",  
      :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"),
      :periodicity => :daily,  
      :comment => "intervalapp.com - #{self.plan.name} Plan",  
      :payments => 0,
      :initial_payment => 0
    }
    
    gateway = ActiveMerchant::Billing::PaypalGateway.new(  
      :login => 'store_1231210306_biz_api1.intervalapp.com',  
      :password => 'YCMXU3VBL737KJG8'
    )
    response = gateway.recurring(self.plan.price * 100, credit_card, options)
    
    if(response.success?)
      write_attribute(:paypal_profile_id, response.params['profile_id'])
    else
      raise StandardError, response.message
    end
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
