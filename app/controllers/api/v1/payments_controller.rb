class Api::V1::PaymentsController < ApplicationController
  def get_order_detail
    order_id = params[:order_id]
    user_id = current_user[:id]

    result = OrderClient.new.get_order_detail(order_id, user_id)

    if result[:success]
      render json: result[:data], status: :ok
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
