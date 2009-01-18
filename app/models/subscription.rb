class Subscription < ActiveRecord::Base
  attr_accessor :credit_card
  belongs_to :user
  belongs_to :plan

  def subscribe
    unless (self.plan.name.eql?('Free'))
      options = {  
        :email => "#{user.email}",  
        :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"),
        :periodicity => :daily,  
        :comment => "intervalapp.com - #{plan.name} Plan",  
        :payments => 0,
        :initial_payment => 0
      }
      
      response = gateway.recurring(self.plan.price, @credit_card, options)
      
      if(response.success?)
        paypal_profile_id = response.params['profile_id']
        save
      else
        raise StandardError, response.message
      end
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
    if (plan.paid?)
      response = gateway.cancel_recurring(:profile_id => paypal_profile_id) 
    end
  end
  
  def credit_card=(card)
    unless (self.plan.name.eql?('Free'))
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :type       => card[:type],
        :number     => card[:number],
        :month      => card[:month],
        :year       => card[:year],
        :first_name => card[:first_name],
        :last_name  => card[:last_name], 
        :verification_value  => card[:verification_value])
    end
  end
  
  private
  
    def gateway 
      @gateway ||= ActiveMerchant::Billing::PaypalGateway.new(  
        :login => 'andrew_1232051849_biz_api1.intervalapp.com',  
        :password => 'EATS3UJSPR8FFBTZ',
        :signature => 'Anpkc8GMNUtWAXPxSeLzLZToGS4DA2kFXQOpd7BLK0k4oaetOvnHMkzI'
      )
    end
    
    def validate_on_create
      unless (self.plan.name.eql?('Free'))
        unless @credit_card.valid?
          @credit_card.errors.each{|attribute, message| errors.add(attribute, message.join(". "))}
        end
      end
    end
end
