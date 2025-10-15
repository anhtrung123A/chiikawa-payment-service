require "grpc"
require "order"

class OrderClient
  def initialize
    @stub = Order::OrderService::Stub.new(
      ENV.fetch("ORDER_SERVICE_URL", "localhost:50051"),
      :this_channel_is_insecure
    )
  end

  def get_order_detail(order_id, user_id)
    request = Order::GetOrderDetailRequest.new(
      order_id: order_id,
      user_id: user_id
    )

    response = @stub.get_order_detail(request)
    { success: true, data: response.to_h }

  rescue GRPC::BadStatus => e
    {
      success: false,
      error_code: e.code,
      error_name: grpc_code_name(e.code),
      message: e.details
    }
  end

  private

  def grpc_code_name(code)
    # Mapping from gRPC status codes to readable names
    {
      GRPC::Core::StatusCodes::OK => "OK",
      GRPC::Core::StatusCodes::CANCELLED => "CANCELLED",
      GRPC::Core::StatusCodes::UNKNOWN => "UNKNOWN",
      GRPC::Core::StatusCodes::INVALID_ARGUMENT => "INVALID_ARGUMENT",
      GRPC::Core::StatusCodes::DEADLINE_EXCEEDED => "DEADLINE_EXCEEDED",
      GRPC::Core::StatusCodes::NOT_FOUND => "NOT_FOUND",
      GRPC::Core::StatusCodes::ALREADY_EXISTS => "ALREADY_EXISTS",
      GRPC::Core::StatusCodes::PERMISSION_DENIED => "PERMISSION_DENIED",
      GRPC::Core::StatusCodes::UNAUTHENTICATED => "UNAUTHENTICATED",
      GRPC::Core::StatusCodes::RESOURCE_EXHAUSTED => "RESOURCE_EXHAUSTED",
      GRPC::Core::StatusCodes::FAILED_PRECONDITION => "FAILED_PRECONDITION",
      GRPC::Core::StatusCodes::ABORTED => "ABORTED",
      GRPC::Core::StatusCodes::OUT_OF_RANGE => "OUT_OF_RANGE",
      GRPC::Core::StatusCodes::UNIMPLEMENTED => "UNIMPLEMENTED",
      GRPC::Core::StatusCodes::INTERNAL => "INTERNAL",
      GRPC::Core::StatusCodes::UNAVAILABLE => "UNAVAILABLE",
      GRPC::Core::StatusCodes::DATA_LOSS => "DATA_LOSS"
    }[code] || "UNKNOWN"
  end
end
