class OrderPublisher
  EXCHANGE_NAME = "order.events"

  def self.publish_order_event(payload, event)
    exchange = $channel.direct(EXCHANGE_NAME)
    payload = { payload: payload, event: event }.to_json

    # routing key dùng để phân loại message, ví dụ: "order.created", "order.cancelled"
    routing_key = "order.#{event}"

    exchange.publish(payload, routing_key: routing_key)
    Rails.logger.info("Published order #{event} event: #{payload} (routing_key: #{routing_key})")
  end
end
