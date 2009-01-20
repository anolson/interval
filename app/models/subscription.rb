class Subscription < ActiveRecord::Base
  attr_accessor :credit_card
  belongs_to :user
  belongs_to :plan

  def subscribe
    unless(plan.paid?)
       
      options = {  
        :email => "#{user.email}",  
        :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"),
        :periodicity => :daily,  
        :comment => "intervalapp.com - #{new_plan.name} Plan",  
        :payments => 0
      }
       
      #trial only for new signups  
      if(self.plan.nil?)
        options.merge(:initial_payment => 0)
      end
        
      response = gateway.recurring(new_plan.price, @credit_card, options)
      
      if(response.success?)
        paypal_profile_id = response.params['profile_id']
        plan = new_plan
        save
      else
        raise StandardError, response.message
      end
    end
  end
  
  def change(new_plan)
    if (plan.paid?)
      if(new_plan.paid?)
        response = gateway.update_recurring(:profile_id => paypal_profile_id) 
      else
        cancel
        paypal_profile_id = ""
      end 
    else
      subscribe(new_plan)
    end
    plan = new_plan
    save
  end


  #TODO put paypal un-subscription here
  def cancel
    if (plan.paid?)
      response = gateway.cancel_recurring(:profile_id => paypal_profile_id) 
    end
  end
  
  def credit_card=(card)
    unless (plan.paid?)
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
  
  def is_within_limits?
    self.class.is_within_limits?(user, plan)
  end
  
  def self.is_within_limits?(user, plan) 
    is_within_workout_limit?(user, plan) && is_within_size_limit?(user, plan)
  end
  
  private
    def self.is_within_workout_limit?(user, plan)
      if(plan.has_workout_limit?)
        if(plan.limit_by.eql?('week'))
          week_start = Date.today.beginning_of_week
          week_end = week_start + 7
          workouts = Workout.find_by_date_range((week_start..week_end), user)
          workouts.size < plan.workout_limit
        else
          user.workouts.size < plan.workout_limit
        end
      else
        return true
      end
    end
  
    def self.is_within_size_limit?(user, plan)
      storage_size = user.workouts.collect{ |workout| workout.training_file.first.file_size }.sum < plan.storage_limit
    end
    
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
