collection @news
attribute :id, :title, :short
node(:url) {|n| news_url(n, :format => :json)}