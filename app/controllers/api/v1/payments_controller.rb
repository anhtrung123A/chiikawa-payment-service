class Api::V1::PaymentsController < ApplicationController
  def create_payment_session
    order_id = params[:order_id]
    user_id = current_user[:id]

    result = OrderClient.new.get_order_detail(order_id, user_id)

    if result[:success]
      order = result[:data]

      begin
        checkout_url = StripePaymentManager.create_payment_session(order)
        render json: { checkout_url: checkout_url }, status: :ok

      rescue StripePaymentManager::PromotionCodeError => e
        render json: { error: e.message }, status: :unprocessable_entity

      rescue StripePaymentManager::StripeSessionError => e
        render json: { error: e.message }, status: :bad_gateway

      rescue => e
        render json: { error: "Unexpected error: #{e.message}" }, status: :internal_server_error
      end

    else
      case result[:error_name]
      when "UNAUTHENTICATED"
        render json: { error: result[:message] }, status: :unauthorized
      when "NOT_FOUND"
        render json: { error: result[:message] }, status: :not_found
      else
        render json: { error: result[:message] }, status: :bad_gateway
      end
    end
  end
end
