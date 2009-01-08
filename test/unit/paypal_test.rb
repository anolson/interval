require File.dirname(__FILE__) + '/../test_helper'

class PaypalTest < Test::Unit::TestCase
  
  def test_recurring
    credit_card = ActiveMerchant::Billing::CreditCard.new(
        :type       => 'visa',
        :number     => '4836047318730937',
        :month      => 1,
        :year       => 2019,
        #:first_name => 'Damiano',
        #:last_name  => 'Cunego',
        :verification_value=> '123'
    )

    #flash[:error] = credit_card.errors and return unless credit_card.valid?

    # billing_address = { 
    #         :name     => "John Smith",
    #         :address1 => '123 First St.',
    #         :address2 => '',
    #         :city     => 'Los Angeles',
    #         :state    => 'CA',
    #         :country  => 'US',
    #         :zip      => '90068',
    #         :phone    => '310-555-1234'
    #     }
    
    
    options = {  
      :name => "Randy Handy", # if not spec'd, the name on card will be used  
      # :profile_id => 'I-SEVK234C8U1M', # triggers :modify on recurring  
      :email => 'damiano@gmail.com',  
      :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"), # change this  
      :periodicity => :monthly,  
      :comment => 'intervalapp.com - pro plan',  
      #:billing_address => billing_address,  
      :payments => 0,  
      :initial_payment => 0  
    }
    
    #if credit_card.valid?
      gateway = ActiveMerchant::Billing::PaypalGateway.new(  
        :login => 'store_1231210306_biz_api1.intervalapp.com',  
        :password => 'YCMXU3VBL737KJG8'
      )

      # Recurring for $10 dollars (1000 cents) 
      response = gateway.recurring(1000, credit_card, options)
      
      #flash[:notice] = response.params['profile_id']

    #end
    puts response.params['profile_id']
    assert response.success?
  end
  
  def test_inquiry
    
  end
end
