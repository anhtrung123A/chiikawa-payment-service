class PromotionPublisher
  EXCHANGE_NAME = "promotion.events"

  def self.publish_promotion_event(promotion_code, event)
    exchange = $channel.direct(EXCHANGE_NAME)
    payload = { promotion_code: promotion_code, event: event }.to_json

    # routing key dùng để phân loại message, ví dụ: "promotion.created", "promotion.cancelled"
    routing_key = "promotion.#{event}"

    exchange.publish(payload, routing_key: routing_key)
    Rails.logger.info("Published promotion #{event} event: #{payload} (routing_key: #{routing_key})")
  end
end
