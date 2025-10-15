class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user_from_jwt
  protect_from_forgery with: :null_session if respond_to?(:protect_from_forgery)

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: :unauthorized
      return
    end

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      handle_checkout_success(session)
    end

    render json: { status: 'ok' }, status: :ok
  end

  private

  def handle_checkout_success(session)
    order_id = session.metadata['order_id'] rescue nil
    # payment_intent = session.payment_intent
    puts "order_id: #{order_id}"
    # puts "payment_intent: #{payment_intent.as_json}"
  end
end
