require File.dirname(__FILE__) + '/../test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  test "create subscription" do
    subscription = Subscription.create(
      { :credit_card => 
        { :type => "visa", 
          :number => "4836047318730937", 
          :month => "11",
          :year => "2010",
          :last_name => "cunego",
          :first_name => "damiano",
          :verification_value => "123"} } )
          
    assert subscription.valid?
    assert_equal "visa", subscription.credit_card.type
    assert_equal "4836047318730937", subscription.credit_card.number
    assert_equal 11, subscription.credit_card.month
    assert_equal 2010, subscription.credit_card.year
    assert_equal "cunego", subscription.credit_card.last_name
    assert_equal "damiano", subscription.credit_card.first_name
    assert_equal "123", subscription.credit_card.verification_value      
    
  end
  
  test "create invalid subscription" do
    subscription = Subscription.create(
      { :credit_card => 
        { :type => "notype", 
          :number => "1234", 
          :month => "22",
          :year => "2008",
          :last_name => "",
          :first_name => "", 
          :verification_value => ""} } )
          
    #puts subscription.credit_card.valid?
    #subscription.credit_card.valid?
    assert subscription.errors.invalid?(:type)
    assert subscription.errors.invalid?(:number)
    assert subscription.errors.invalid?(:month)
    assert subscription.errors.invalid?(:year)
    assert subscription.errors.invalid?(:last_name)
    assert subscription.errors.invalid?(:first_name)
    assert subscription.errors.invalid?(:verification_value)
    assert_equal false, subscription.valid?
    
  end
end
