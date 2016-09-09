json.array!(@locations) do |location|
  json.extract! location, :latitude, :longitude, :title
  json.url location_url(location, format: :json)
end
