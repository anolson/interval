# The MIT License
#
# Copyright (c) 2008 Vuzit.com, Chris Cera, Tobias Luetke
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rubygems'
require 'active_merchant'

module ActiveMerchant #:nodoc:
module Billing #:nodoc:
class PaypalGateway < Gateway

# I invented the :suspend action, and this doesn't appear in payflow.rb
RECURRING_ACTIONS = Set.new([:add, :cancel, :inquiry, :suspend])

@@API_VERSION = '50.0' # not sure if this overrides the variable in PaypalCommonAPI

# Several options are available to customize the recurring profile:
#
# * <tt>profile_id</tt> - is only required for editing a recurring profile
# * <tt>starting_at</tt> - takes a Date, Time, or string in mmddyyyy format. The date must be in the future.
# * <tt>name</tt> - The name of the customer to be billed. If not specified, the name from the credit card is used.
# * <tt>periodicity</tt> - The frequency that the recurring payments will occur at. Can be one of
# :bimonthly, :monthly, :biweekly, :weekly, :yearly, :daily, :semimonthly, :quadweekly, :quarterly, :semiyearly
# * <tt>payments</tt> - The term, or number of payments that will be made
# * <tt>comment</tt> - A comment associated with the profile
def recurring(money, credit_card, options = {})
  options[:name] = credit_card.name if options[:name].blank? && credit_card
  request = build_recurring_request(options[:profile_id] ? :modify : :add, money, options) do |xml|
    add_credit_card(xml, credit_card, options[:billing_address], options) if credit_card
  end
  commit('CreateRecurringPaymentsProfile', request)
end

# cancels an existing recurring profile
def cancel_recurring(profile_id)
  request = build_recurring_request(:cancel, 0, :profile_id => profile_id) {}
  commit('ManageRecurringPaymentsProfileStatus', request)
end

# retrieves information about a recurring profile
def recurring_inquiry(profile_id, options = {})
  request = build_recurring_request(:inquiry, nil, options.update( :profile_id => profile_id ))
  commit('GetRecurringPaymentsProfileDetails', request)
end

# suspends a recurring profile
def suspend_recurring(profile_id)
  request = build_recurring_request(:suspend, 0, :profile_id => profile_id) {}
  commit('ManageRecurringPaymentsProfileStatus', request)
end

private

def build_recurring_request(action, money, options)
  unless RECURRING_ACTIONS.include?(action)
    raise StandardError, "Invalid Recurring Profile Action: #{action}"
  end

  xml = Builder::XmlMarkup.new :indent => 2

  ns2 = 'n2:'

  if [:add].include?(action)
    xml.tag! 'CreateRecurringPaymentsProfileReq', 'xmlns' => PAYPAL_NAMESPACE do
      xml.tag! 'CreateRecurringPaymentsProfileRequest' do
        xml.tag! 'Version', @@API_VERSION, 'xmlns' => EBAY_NAMESPACE

        # NOTE: namespace prefix here is critical!
        xml.tag! ns2 + 'CreateRecurringPaymentsProfileRequestDetails ', 'xmlns:n2' => EBAY_NAMESPACE do

          # credit card and other information goes here
          yield xml

          xml.tag! ns2 + 'RecurringPaymentsProfileDetails' do
            xml.tag! ns2 + 'BillingStartDate', options[:starting_at]
          end

          xml.tag! ns2 + 'ScheduleDetails' do
            xml.tag! ns2 + 'Description', options[:comment]

            unless options[:initial_payment].nil?
              xml.tag! ns2 + 'TrialPeriod' do
                xml.tag! ns2 + 'BillingPeriod', 'Month'
                xml.tag! ns2 + 'BillingFrequency', 1
                xml.tag! ns2 + 'TotalBillingCycles', 1
                xml.tag! ns2 + 'Amount', amount(options[:initial_payment]), 'currencyID' => options[:currency] || currency(options[:initial_payment])
              end
            end

            frequency, period = get_pay_period(options)
            xml.tag! ns2 + 'PaymentPeriod' do
              xml.tag! ns2 + 'BillingPeriod', period
              xml.tag! ns2 + 'BillingFrequency', frequency.to_s
              xml.tag! ns2 + 'TotalBillingCycles', options[:payments] unless options[:payments].nil? || options[:payments] == 0
              xml.tag! ns2 + 'Amount', amount(money), 'currencyID' => options[:currency] || currency(money)
            end

            xml.tag! ns2 + 'AutoBillOutstandingAmount', 'AddToNextBilling'
          end
        end
      end
    end
  elsif [:cancel, :suspend].include?(action)
    xml.tag! 'ManageRecurringPaymentsProfileStatusReq', 'xmlns' => PAYPAL_NAMESPACE do
      xml.tag! 'ManageRecurringPaymentsProfileStatusRequest', 'xmlns:n2' => EBAY_NAMESPACE do
        xml.tag! ns2 + 'Version', @@API_VERSION
        xml.tag! ns2 + 'ManageRecurringPaymentsProfileStatusRequestDetails' do
          xml.tag! 'ProfileID', options[:profile_id]
          xml.tag! ns2 + 'Action', action == :cancel ? 'Cancel' : 'Suspend'
          xml.tag! ns2 + 'Note', 'Canceling the action, no real comment here'
        end
      end
    end
  elsif [:inquiry].include?(action)
    xml.tag! 'GetRecurringPaymentsProfileDetailsReq', 'xmlns' => PAYPAL_NAMESPACE do
      xml.tag! 'GetRecurringPaymentsProfileDetailsRequest', 'xmlns:n2' => EBAY_NAMESPACE do
        xml.tag! ns2 + 'Version', @@API_VERSION
        xml.tag! 'ProfileID', options[:profile_id]
      end
    end
  end
end

def get_pay_period(options)
  requires!(options, [:periodicity, :bimonthly, :monthly, :biweekly, :weekly, :yearly, :daily, :semimonthly, :quadweekly, :quarterly, :semiyearly])
  case options[:periodicity]
    when :weekly then [1, 'Week']
    when :biweekly then [2, 'Week']
    when :semimonthly then [1, 'SemiMonth']
    when :quadweekly then [4, 'Week']
    when :monthly then [1, 'Month']
    when :quarterly then [3, 'Month']
    when :semiyearly then [6, 'Month'] # broken! i think
    when :yearly then [1, 'Year']
  end
end

end
end
end