Rails.application.routes.draw do
  root to: "documents#index"
  resources :documents do
    post "top/:input_id", to: "documents#input_move_top"
    post "up/:input_id", to: "documents#input_move_up"
    post "down/:input_id", to: "documents#input_move_down"
    post "bottom/:input_id", to: "documents#input_move_bottom"
    delete ":input_id", to: "documents#input_destroy"
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
