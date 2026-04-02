philippines = Country.create!(
  name: "Philippines",
  description: "Primary operating country for the school management sample data."
)

Country.create!(name: "United States", description: "Reference country for international record samples.")

ncr = Region.create!(name: "National Capital Region", country: philippines, description: "Metro Manila administrative region.")
calabarzon = Region.create!(name: "CALABARZON", country: philippines, description: "Region IV-A")

metro_manila = Province.create!(name: "Metro Manila", region: ncr, description: "Metro Manila")
laguna = Province.create!(name: "Laguna", region: calabarzon, description: "Laguna province")

quezon_city = City.create!(name: "Quezon City", province: metro_manila, description: "Largest city in Metro Manila", is_municipality: false)
manila = City.create!(name: "Manila", province: metro_manila, description: "Capital city of the Philippines", is_municipality: false)
sta_rosa = City.create!(name: "Santa Rosa", province: laguna, description: "Laguna growth center", is_municipality: false)

Barangay.create!(name: "Bagumbayan", city: quezon_city, description: "Sample barangay for QC")
Barangay.create!(name: "Commonwealth", city: quezon_city, description: "Sample barangay for QC")
Barangay.create!(name: "Barangay 659", city: manila, description: "Sample barangay for Manila")
Barangay.create!(name: "Aplaya", city: sta_rosa, description: "Sample barangay for Santa Rosa")
