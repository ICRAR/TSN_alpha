atom_feed do |feed|
  feed.title "theSkyNet Latest News"
  feed.updated @news.maximum(:updated_at)
  @news.each do |item|
    feed.entry item do |entry|
      entry.title item.title
      entry.content item.long, type: 'html'
      entry.author do |author|
        author.name "theSkyNet"
      end
    end
  end
end

