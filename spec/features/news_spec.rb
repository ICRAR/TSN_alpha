require 'spec_helper'

feature "Pages" do
  describe "Viewing on website", :js => true  do
    scenario "base news iteam" do
      news_item = Fabricate(:news_with_image).reload
      visit news_path(news_item)
      #display title
      screenshot_and_open_image
      expect(page).to have_css('h1', :text => news_item.title)
      #display content
      expect(page).to have_html(news_item.content)
    end

  end


end
