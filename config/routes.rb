Rails.application.routes.draw do
  root to: "documents#index"
  resources :documents do
    post "up/:input_id", to: "documents#input_move_up"
    post "down/:input_id", to: "documents#input_move_down"
    delete ":input_id", to: "documents#input_destroy"
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
