Fabricator(:science_portal) do
  slug { sequence(:science_portal_name) { |i| "Science #{i}" } }
  name { |attrs| attrs[:slug] }
  public true
  desc { "<h1>#{Faker::Company.catch_phrase}</h1>"\
            "<p>#{Faker::Lorem.paragraph(5)}</p>"
  }
  leaders {[Fabricate(:user).reload.profile]}
end
Fabricator(:science_portal_with_links, from: :science_portal) do
  science_links {2.times.map{ Fabricate(:science_link) }}
end

Fabricator(:science_link) do
  name { sequence(:science_portal_link_name) { |i| "Some Science link #{i}" } }
  url { Faker::Internet.url}
end