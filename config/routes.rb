# config/routes.rb
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  get 'documentos', to: 'documentos#index'
  post '/enviar_arquivo', to: 'documentos#enviar_arquivo'

  root 'documentos#index'
end
