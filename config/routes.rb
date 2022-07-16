Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: "documents#index"
  resources :documents, except: [:show] do
    post "top/:input_id", to: "documents#input_move_top"
    post "up/:input_id", to: "documents#input_move_up"
    post "down/:input_id", to: "documents#input_move_down"
    post "bottom/:input_id", to: "documents#input_move_bottom"
    delete ":input_id", to: "documents#input_destroy"
  end
end
