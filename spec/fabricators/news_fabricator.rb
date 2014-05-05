Fabricator(:news) do
  long {Faker::Lorem.paragraph(5) }
  short {Faker::Lorem.paragraph(1) }
  title {Faker::Lorem.words(4) }
  published  true
  published_time Time.now
  image
  notify false
end

Fabricator(:news_with_image, from: :news) do
  image { File.open(File.join(Rails.root, 'spec', 'fabricators', 'assets', 'logo_halloween.png'))}
end
