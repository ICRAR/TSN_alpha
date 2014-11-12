atom_feed do |feed|
  feed.title "theSkyNet Latest Galaxy Mosaics"
  feed.updated @mosaics.maximum(:updated_at)
  @mosaics.each do |mosaic|
    feed.entry mosaic do |entry|
      time = mosaic.image_updated_at.strftime '%B %d, %Y'
      entry.title time
      entry.content "A new galaxy Mosaic was created at theSkyNet.org on #{time}."
      entry.author do |author|
        author.name "theSkyNet"
      end
    end
  end
end

