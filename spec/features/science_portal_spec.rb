require 'spec_helper'

feature "SciencePortal" do
=begin
  describe "Viewing on portal page"  do
    scenario "basic display" do
      sp = Fabricate(:science_portal).reload
      visit science_portal_path(sp)
      #display title
      expect(page).to have_css('h1', :text => sp.name)
      #display content
      expect(page).to have_html(sp.desc)

      #link to all projects
      page.should have_link('All Projects')
      click_link('All Projects')
      expect(page).to have_css('h1', :text => 'theSkyNet Science Projects')

      visit science_portal_path(sp)
      #link to self
      page.should have_link(sp.name)
      click_link (sp.name)
      expect(page).to have_css('h1', :text => sp.name)
    end
    scenario "show and link to leaders" do
      #list leaders
      sp = Fabricate(:science_portal).reload
      visit science_portal_path(sp)
      sp.leaders.each do |leader|
        within('#leaders') do
          page.should have_content(leader.name)
          click_link(leader.name)
        end
        page.should have_content("Name: #{leader.name}")
        visit science_portal_path(sp)
      end
    end
    scenario "show links" do
      #list leaders
      sp = Fabricate(:science_portal_with_links).reload
      visit science_portal_path(sp)
      #list links
      within('#links') do
        sp.science_links.each do |link|
          page.should have_link(link.name, href: link.url)
        end
      end
    end
    scenario "child pages" do
      sp = Fabricate(:science_portal_with_pages).reload
      visit science_portal_path(sp)
      page.should have_link(sp.pages.first.title)

      click_link (sp.pages.first.title)

      #display SP name
      expect(page).to have_css('h1', :text => sp.name)
      #and page content
      expect(page).to have_html(sp.pages.first.content)

      #link back to SP
      page.should have_link(sp.name)
      click_link (sp.name)
      expect(page).to have_css('h1', :text => sp.name)
      page.should_not have_html(sp.pages.first.content)
    end

  end
  describe "Viewing Index page" do
    scenario "index page should list all projects" do
      sps = 3.times.map{ Fabricate(:science_portal).reload }

      visit science_portals_path

      #display title
      expect(page).to have_css('h1', :text => 'theSkyNet Science Projects')

      #list projects
      sps.each do |sp|
        page.should have_link(sp.name)
      end
      click_link (sps.first.name)

      page.should have_css('h1', :text => sps.first.name)
      page.should have_html(sps.first.desc)
    end
  end
=end
  describe "Private portal" do
    scenario "portal should not show up in public index" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portals_path

      page.should_not have_link(sp.name)

    end
    scenario "portal should block accsess" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portal_path(sp)

      page.should_not have_content(sp.name)
      page.should have_content('Sorry you are not authorised to view that project')

    end
    scenario "portal should show up in public index for members" do
      sp = Fabricate(:science_portal, public: false).reload
      user = Fabricate(:user)
      sp.members << user.profile
      as_user user
      visit science_portals_path

      page.should have_link(sp.name)
    end

    scenario "access should be granted too members" do
      sp = Fabricate(:science_portal, public: false).reload
      user = Fabricate(:user)
      sp.members << user.profile
      as_user user
      visit science_portal_path(sp)

      page.should have_content(sp.name)
      page.should have_html(sp.desc)
    end
  end
end
