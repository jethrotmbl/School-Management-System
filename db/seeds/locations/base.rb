puts "Loading static location seed data..."

load Rails.root.join("db", "seeds", "countries.rb")
load Rails.root.join("db", "seeds", "regions.rb")
load Rails.root.join("db", "seeds", "provinces.rb")
load Rails.root.join("db", "seeds", "cities.rb")
load Rails.root.join("db", "seeds", "barangays.rb")

COUNTRY_NAMES.each do |name|
  Country.create!(name: name)
end

philippines = Country.find_by!(name: "Philippines")

REGION_NAMES.each do |name|
  Region.create!(name: name, country: philippines)
end

PROVINCE_DATA.each do |region_name, province_names|
  region = Region.find_by!(name: region_name)

  province_names.each do |province_name|
    Province.create!(name: province_name, region: region)
  end
end

CITY_DATA.each do |province_name, city_name, is_municipality|
  province = Province.find_by!(name: province_name)

  City.create!(
    name: city_name,
    province: province,
    is_municipality: is_municipality
  )
end

BARANGAY_DATA.each do |barangay_data|
  province = Province.find_by!(name: barangay_data[:province_name])
  city = City.find_by!(name: barangay_data[:city_name], province: province)

  Barangay.create!(
    name: barangay_data[:name],
    city: city
  )
end

puts "Static locations loaded: #{Country.count} countries, #{Region.count} regions, #{Province.count} provinces, #{City.count} cities/municipalities, #{Barangay.count} barangays."

