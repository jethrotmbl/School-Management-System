unless defined?(COUNTRY_NAMES)
	load Rails.root.join("db", "seeds", "countries.rb")
end

DEMONYM_BY_COUNTRY = {
	"Philippines" => "Filipino",
	"Australia" => "Australian",
	"United States" => "American",
	"United Kingdom" => "British",
	"New Zealand" => "New Zealander",
	"Canada" => "Canadian",
	"Japan" => "Japanese",
	"China" => "Chinese",
	"South Korea" => "South Korean",
	"North Korea" => "North Korean",
	"Vietnam" => "Vietnamese",
	"Thailand" => "Thai",
	"Indonesia" => "Indonesian",
	"Malaysia" => "Malaysian",
	"Singapore" => "Singaporean",
	"India" => "Indian",
	"Pakistan" => "Pakistani",
	"Bangladesh" => "Bangladeshi",
	"Saudi Arabia" => "Saudi",
	"United Arab Emirates" => "Emirati",
	"Qatar" => "Qatari",
	"Kuwait" => "Kuwaiti",
	"Oman" => "Omani",
	"Bahrain" => "Bahraini",
	"Egypt" => "Egyptian",
	"South Africa" => "South African",
	"Nigeria" => "Nigerian",
	"Kenya" => "Kenyan",
	"Ethiopia" => "Ethiopian",
	"France" => "French",
	"Germany" => "German",
	"Italy" => "Italian",
	"Spain" => "Spanish",
	"Portugal" => "Portuguese",
	"Netherlands" => "Dutch",
	"Switzerland" => "Swiss",
	"Greece" => "Greek",
	"Sweden" => "Swedish",
	"Norway" => "Norwegian",
	"Denmark" => "Danish",
	"Finland" => "Finnish",
	"Poland" => "Polish",
	"Czech Republic" => "Czech",
	"Romania" => "Romanian",
	"Hungary" => "Hungarian",
	"Russia" => "Russian",
	"Turkey" => "Turkish",
	"Iran" => "Iranian",
	"Iraq" => "Iraqi",
	"Israel" => "Israeli",
	"Mexico" => "Mexican",
	"Brazil" => "Brazilian",
	"Argentina" => "Argentine",
	"Chile" => "Chilean",
	"Colombia" => "Colombian",
	"Peru" => "Peruvian",
	"Venezuela" => "Venezuelan"
}.freeze

COUNTRY_NAMES.each do |country_name|
	citizenship_name = DEMONYM_BY_COUNTRY.fetch(country_name, country_name)

	Citizenship.create!(
		name: citizenship_name,
		description: "Citizen of #{country_name}."
	)
end
