Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "/payment/create_session", to: "payments#create_payment_session"
      post '/webhooks/stripe', to: 'webhooks#stripe'
    end
  end
end
