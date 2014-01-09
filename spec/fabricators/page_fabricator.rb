Fabricator(:page) do
  slug { sequence(:page_name) { |i| "Page #{i}" } }
  page_translations(count:1)  { |attrs|Fabricate(:page_translation, title: "About: #{attrs[:slug]}")}
  preview false
  parent_id nil
  sort_order 0
end
Fabricator(:about_page, from: :page) do
  slug "About"
  page_translations(count:1) { Fabricate(:page_translation, title: "About: Parent Page")}
end
Fabricator(:with_french, from: :page) do
  page_translations  {[
      Fabricate(:page_translation, title: "English Title", content: "English Content"),
      Fabricate(:page_translation, title: "French Title", content: "French Content", locale: 'fr'),
  ]}
end
Fabricator(:page_translation) do
  title "Page Title"
  content { "<h1>#{Faker::Company.catch_phrase}</h1>"\
            "<p>#{Faker::Lorem.paragraph(5)}</p>"
  }
  locale 'en'
end