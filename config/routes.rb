Rails.application.routes.draw do
  scope path: ApplicationResource.endpoint_namespace, defaults: { format: :jsonapi } do
    resources :authors, only: %i[index show] do
      member do
        get :recipe_stats
      end
    end
    resources :categories, only: :index
    resources :recipes, only: %i[index show] do
      member do
        post 'like'
        delete 'unlike'
        post 'feature'
        delete 'unfeature'
      end
    end
    resources :likes, only: %i[index]

    mount VandalUi::Engine, at: '/vandal'
  end
end
