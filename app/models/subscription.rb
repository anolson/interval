class Subscription < ActiveRecord::Base
  attr_accessor :credit_card
  belongs_to :user
  belongs_to :plan
  
  def subscribe
    if(plan.paid?)
      options = {  
        :email => user.email,  
        :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"),
        :periodicity => :daily,  
        :comment => "intervalapp.com - #{plan.name} Plan",  
        :payments => 0, 
        :initial_payment => 0
      }      
      recurring(self.plan, options)
    end
  end
  
  def change(new_plan)
    if (plan.paid?)
      if(new_plan.paid?)
        change_from_paid_to_paid(new_plan)
      else
        change_from_paid_to_free(new_plan)
      end 
    else
      change_from_free_to_paid(new_plan)
    end
  end
  
  def details()
    if(plan.paid?)
      response = gateway.recurring_inquiry(paypal_profile_id) 
      response.params
    end
  end

  def cancel
    if (plan.paid?)
      response = gateway.cancel_recurring(paypal_profile_id) 
      #raise response.message.to_s
    end
  end
  
  def credit_card=(card)
    #unless (plan.paid?)
    #raise card.nil?.to_s
    unless(card.nil?)
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
    def change_from_paid_to_paid(new_plan)
      options = {
        :profile_id => paypal_profile_id
      }
      recurring(new_plan, options)
    end
    
    def change_from_paid_to_free(new_plan)
      cancel
      self.paypal_profile_id = nil
      self.plan = new_plan
      save!
    end
    
    def change_from_free_to_paid(new_plan)
      options = {  
        :email => user.email,  
        :starting_at => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S"),
        :periodicity => :daily,  
        :comment => "intervalapp.com - #{new_plan.name} Plan",  
        :payments => 0, 
        :initial_payment => nil
      }
      recurring(new_plan, options)
    end

    def recurring(new_plan, options = {})
      if(new_plan.paid?)
        response = gateway.recurring(new_plan.price, @credit_card, options)
        if(response.success?)
          self.paypal_profile_id = response.params['profile_id']
          self.plan = new_plan
          save!
        else
          raise StandardError, response.message
        end
      end
    end

    def self.is_within_workout_limit?(user, plan)
      if(plan.has_workout_limit?)
        if(plan.limit_by.eql?('week'))
          week_start = Date.today.beginning_of_week
          week_end = week_start + 7
          workouts = Workout.find_by_created_at_range((week_start..week_end), user)
          workouts.size < plan.workout_limit
        else
          user.workouts.size < plan.workout_limit
        end
      else
        return true
      end
    end
  
    def self.is_within_size_limit?(user, plan)
      workouts = user.workouts.collect { |workout| 
        workout.has_training_files? && workout.training_file.first.file_size || 0
      }
      workouts.sum < plan.storage_limit
    end
    
    def gateway 
      @gateway ||= ActiveMerchant::Billing::PaypalGateway.new(  
        :login => $PAYPAL_LOGIN,  
        :password => $PAYPAL_PASSWORD,
        :signature => $PAYPAL_SIGNATURE
      )
    end
    
    def validate
      unless @credit_card.nil?
        unless @credit_card.valid?
          @credit_card.errors.each{|attribute, message| errors.add(attribute, message.join(". "))}
        end
      end
    end
end
