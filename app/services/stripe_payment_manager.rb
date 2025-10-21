class StripePaymentManager
  class PromotionCodeError < StandardError; end
  class StripeSessionError < StandardError; end

  def self.create_payment_session(order)
    line_items = order[:items].map do |item|
      {
        price_data: {
          currency: 'jpy',
          product_data: { 
            name: item[:name],
            images: [item[:image]]
          },
          unit_amount: item[:price].to_i
        },
        quantity: item[:quantity]
      }
    end

    # --- Handle promotion code only if present ---
    discounts = []
    if order[:promotion_code].present?
      promo = Stripe::PromotionCode.list(code: order[:promotion_code], active: true).data.first
      raise PromotionCodeError, "Invalid or expired promotion code" if promo.nil?
      discounts << { promotion_code: promo.id }
    end

    session = Stripe::Checkout::Session.create(
      mode: 'payment',
      line_items: line_items,
      discounts: discounts, # safe: empty array if no promo
      success_url: "http://localhost:5173/payment/success/#{order[:order_id]}",
      cancel_url: 'https://google.com?canceled=true',
      metadata: {
        order_id: order[:order_id],
        promotion_code: order[:promotion_code]
      }
    )

    session.url
  rescue Stripe::StripeError => e
    raise StripeSessionError, e.message
  end
end
