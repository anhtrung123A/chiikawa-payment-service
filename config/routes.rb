Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "/test", to: "payments#get_order_detail"
    end
  end
end
