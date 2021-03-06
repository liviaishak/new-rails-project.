class ChargesController < ApplicationController
  def create
     @amount = 1500
     # Creates a Stripe Customer object, for associating
     # with the charge
     customer = Stripe::Customer.create(
       email: current_user.email,
       card: params[:stripeToken]
     )

     # Where the real magic happens
     charge = Stripe::Charge.create(
       customer: customer.id, # Note -- this is NOT the user_id in your app
       amount: @amount,
       description: "BigMoney Membership - #{current_user.email}",
       currency: 'usd'
     )

     flash[:notice] = "Thank you for the payment and upgrading your account to Premium, #{current_user.email}!"
     current_user.update_attribute(:role, 'premium')
     redirect_to edit_user_registration_path

     # Stripe will send back CardErrors, with friendly messages
     # when something goes wrong.
     # This `rescue block` catches and displays those errors.
     rescue Stripe::CardError => e
       flash[:alert] = e.message
       redirect_to new_charge_path
 end
   def new
     @stripe_btn_data = {
       key: "#{ Rails.configuration.stripe[:publishable_key] }",
       description: "BigMoney Membership - #{current_user.email}",
       amount: @amount
     }
   end
end
