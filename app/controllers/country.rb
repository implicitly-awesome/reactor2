Reactor2::App.controllers :country do
  before {content_type :json}

  # Get the list of countries
  get :index, map: '/api/NSI/countries' do
    if Padrino.cache.get('NSI_countries').nil?
      countries = []
      Country.all.each do |c|
        countries << c.to_json_rabl('NSI/country/show')
      end
      Padrino.cache.set('NSI_countries', countries.to_json, expires_in: 10)
    end
    response = Padrino.cache.get('NSI_countries')
  end

  # Get exact user from the list
  get :show, map: '/api/NSI/countries/:guid' do
    country = Country.get(params[:guid]).to_json_rabl('NSI/country/show')
    Padrino.cache.set("NSI_country_#{params[:guid]}", country, expires_in: 10)
    response = Padrino.cache.get("NSI_country_#{params[:guid]}")
  end


  private

  def restrict_access
    api_key = ApiKey.get(params[:access_token])
    head :unauthorized unless api_key
  end
end
