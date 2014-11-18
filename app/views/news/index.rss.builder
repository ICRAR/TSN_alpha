xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "theSkyNet Latest News"
    xml.description "Latest News articles from theSkyNet.org"
    xml.link news_index_url

    @news.each do |article|
      xml.item do
        xml.title article.title
        xml.description article.long
        xml.pubDate article.published_time.to_s(:rfc822)
        xml.link news_url(article)
        xml.guid news_url(article)
      end
    end
  end
end
