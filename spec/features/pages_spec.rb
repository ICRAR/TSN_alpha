require 'spec_helper'

feature "Pages" do
  describe "Viewing on website", :js => true  do
    scenario "with no parent or children" do
      new_page = Fabricate(:page, slug: 'Test Page').reload
      visit page_path(new_page)
      #display title
      expect(page).to have_css('h1', :text => new_page.title)
      #display content
      expect(page).to have_html(new_page.content)
    end

    scenario "trying to view non existent page"  do
      Fabricate(:page, slug: '404')
      visit page_path(:slug => "some_page")
      expect(page).to have_content "404"
    end

    scenario "with no parent and with siblings" do
      parent_page = Fabricate(:page, slug: 'parent').reload
      ch1_page = Fabricate(:page, parent_id: parent_page.id, sort_order:3).reload
      ch2_page = Fabricate(:page, parent_id: parent_page.id, sort_order:1).reload
      ch3_page = Fabricate(:page, parent_id: parent_page.id, sort_order:2).reload

      second_parent_page = Fabricate(:page, slug: 'parent2').reload
      second_ch_page = Fabricate(:page, parent_id: second_parent_page.id).reload



      visit page_path(parent_page)
      #should still display it's own title
      expect(page).to have_css('h1', :text => parent_page.title)
      #should display it's own content
      expect(page).to have_html(parent_page.content)

      #display links to children
      expect(page).to have_css('a', :text => ch1_page.title)
      expect(page).to have_css('a', :text => ch2_page.title)
      expect(page).to have_css('a', :text => ch3_page.title)

      #in correct order
      within "#page-nav" do
        ch3_page.title.should appear_before(ch1_page.title)
        ch2_page.title.should appear_before(ch3_page.title)
      end

      #check that the other pages are not displayed
      expect(page).not_to have_css('a', :text => second_ch_page.title)
      expect(page).not_to have_content second_parent_page.title


      #click on a link will go to that page
      click_link ch2_page.title

      expect(page).to have_html(ch2_page.content)
    end

    scenario "with a parent and siblings" do
      parent_page = Fabricate(:page, slug: 'parent').reload
      ch1_page = Fabricate(:page, parent_id: parent_page.id, sort_order:3).reload
      ch2_page = Fabricate(:page, parent_id: parent_page.id, sort_order:1).reload
      ch3_page = Fabricate(:page, parent_id: parent_page.id, sort_order:2).reload

      visit page_path(ch1_page)
      #should still display its parent's title
      expect(page).to have_css('h1', :text => parent_page.title)
      #should display it's own content
      expect(page).to have_html(ch1_page.content)

      #display links to siblings
      expect(page).to have_css('a', :text => ch1_page.title)
      expect(page).to have_css('a', :text => ch2_page.title)
      expect(page).to have_css('a', :text => ch3_page.title)

      #in correct order
      within "#page-nav" do
        ch3_page.title.should appear_before(ch1_page.title)
        ch2_page.title.should appear_before(ch3_page.title)
      end

      #with the current page marked as active
      expect(page).to have_css('li.active', :text => ch1_page.title)

      #click on a link will go to that page
      click_link ch2_page.title
      expect(page).to have_html(ch2_page.content)
      #with the new page marked as active
      expect(page).to have_css('li.active', :text => ch2_page.title)
    end
    scenario "with translation" do
      test_page = Fabricate(:with_french).reload
      visit page_path(test_page, locale: 'en')
      I18n.locale = :en
      expect(page).to have_css('h1', :text => test_page.title)
      visit page_path(test_page, locale: 'fr')
      I18n.locale = :en
      expect(page).not_to have_css('h1', :text => test_page.title)
      I18n.locale = :fr
      expect(page).to have_css('h1', :text => test_page.title)
    end
  end
  describe "preview Pages as Admin" do
    given(:parent_page) {Fabricate(:page, slug: 'parent').reload}
    given(:ch1_page)    {Fabricate(:page, parent_id: parent_page.id ).reload}
    given(:ch2_page_private)    {Fabricate(:page, parent_id: parent_page.id, preview: true).reload}

    scenario "can't view a preview page as a guest"  do
      Fabricate(:page, slug: '404').reload
      visit page_path(ch2_page_private)
      expect(page).to have_content "404"
      expect(page).not_to have_html(ch2_page_private.content)
    end

    scenario "can't see link to preview page as guest" do
      ch1_page
      ch2_page_private
      visit page_path(parent_page)
      expect(page).to have_css('a', :text => ch1_page.title)
      expect(page).not_to have_css('a', :text => ch2_page_private.title)
    end

    scenario "can see link to preview page as admin" do
      ch1_page
      ch2_page_private
      as_user Fabricate(:admin)

      visit page_path(parent_page)

      expect(page).to have_css('a', :text => ch1_page.title)
      expect(page).to have_css('a', :text => ch2_page_private.title)
    end

    scenario "can view a preview page as admin" do
      Fabricate(:page, slug: '404')
      as_user Fabricate(:admin)

      visit page_path(ch2_page_private)
      expect(page).to have_html(ch2_page_private.content)
    end
  end

  describe "Create Page as Admin", :js => true do
    scenario "create basic page" do
      as_user Fabricate(:admin)
      slug = "test_page1"
      title = "Test Page Title"
      content = Faker::Lorem.paragraph(5)
      visit rails_admin.new_path(model_name: 'page')
      fill_in('Slug', with: slug)
      click_on('Add a new Page translation')
      fill_in('Locale', with: "en")
      fill_in('Title', with: title)
      fill_in_ckeditor('#cke_1_contents', content)

      click_button("Save")

      visit page_path(slug: slug )
      expect(page).to have_html(content)

    end
  end

  describe "Index Page" do
    scenario "no index page set" do
      visit root_path
      page.should have_content("hello world")
    end
    scenario "index page set" do
      index_page = Fabricate(:page, slug: 'index').reload
      visit root_path
      page.should have_html(index_page.content)
    end
    scenario "main content" do
      visit root_path

      #check that the main content is displayed
      page.should have_content("Play your part and help discover our Universe!")
      page.should have_content("Why should I join?")
      page.should have_content("Current Server Time:")
    end
    scenario "Global stats graphs", :js => true, :driver => :selenium do
      visit root_path

      #check that the main graphs are displayed
      page.should have_selector('#tab-global.active')
      within('#tab-global.active') do
        page.should have_selector('#chart')
      end
      click_link 'POGS Stats'

      page.should have_selector('#tab-boinc.active')
      within('#tab-boinc.active') do
        page.should have_selector('#chart')
      end
      click_link 'SourceFinder Stats'

      page.should have_selector('#tab-nereus.active')
      within('#tab-nereus.active') do
        page.should have_selector('#chart')
      end
    end
    scenario "leaderboards" do
      visit root_path
      page.should have_content("leaderboards")
      #Todo add 11 users and check that top 10 appear
      #Todo same for alliances
    end
    scenario "TFLOPS indicator", :js => true do
      SiteStat.set('global_TFLOPS', 12.88)

      visit root_path
      page.should have_content("12.88")
      page.should have_content("TFLOPS")
    end
  end


end
