[
  ["BASIC-ED", "Basic Education", "Handles elementary and junior high academic delivery."],
  ["STEM", "STEM Department", "Science, technology, engineering, and mathematics programs."],
  ["ABM", "ABM Department", "Accountancy, business, and management strand."],
  ["HUMSS", "HUMSS Department", "Humanities and social sciences strand."],
  ["ADMIN", "Academic Affairs", "Institutional academic operations and faculty coordination."]
].each do |code, name, description|
  Department.create!(code: code, name: name, description: description)
end
