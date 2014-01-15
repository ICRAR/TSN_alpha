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
  describe "Private portal" do
    scenario "portal should not show up in public index to guests" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portals_path

      page.should_not have_link(sp.name)

    end
    scenario "portal should block accsess to guests" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portal_path(sp)

      page.should_not have_content(sp.name)
      page.should have_content('Sorry you are not authorised to view that project')

    end
    scenario "portal should not show up in public index to no portal members" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portals_path
      user = Fabricate(:user)
      as_user user

      page.should_not have_link(sp.name)

    end
    scenario "portal should block accsess to public to no portal members" do
      sp = Fabricate(:science_portal, public: false).reload
      visit science_portal_path(sp)
      user = Fabricate(:user)
      as_user user

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
    scenario "portal should show up in public index for leaders" do
      sp = Fabricate(:science_portal, public: false).reload
      user = Fabricate(:user)
      sp.leaders << user.profile
      as_user user
      visit science_portals_path

      page.should have_link(sp.name)
    end

    scenario "access should be granted too leaders" do
      sp = Fabricate(:science_portal, public: false).reload
      user = Fabricate(:user)
      sp.leaders << user.profile
      as_user user
      visit science_portal_path(sp)

      page.should have_content(sp.name)
      page.should have_html(sp.desc)
    end
  end
  describe "Create new science portal in admin interface" do
    scenario "Create Basic public Page", :js => true  do
      as_user Fabricate(:admin)
      slug = "test_portal_1"
      name = "Test Protal Title"
      desc = Faker::Lorem.paragraph(5)
      visit rails_admin.new_path(model_name: 'science_portal')

      fill_in('Slug', with: slug)
      fill_in('Name', with: name)
      fill_in_ckeditor('#cke_1_contents', desc)
      check('Public')
      click_button("Save")

      visit science_portal_path(id: slug )
      expect(page).to have_html(desc)
      expect(page).to have_css('h1', :text => name)
    end
    scenario "Create private Page with leader and members", :js => true  do
      leader = Fabricate(:admin).reload
      user = Fabricate(:user).reload
      slug = "test_portal_1"
      name = "Test Protal Title"
      desc = Faker::Lorem.paragraph(5)
      as_user leader do

        visit rails_admin.new_path(model_name: 'science_portal')

        fill_in('Slug', with: slug)
        fill_in('Name', with: name)
        fill_in_ckeditor('#cke_1_contents', desc)

        habtm_select('#science_portal_leader_ids_field', leader.profile.name)
        habtm_select('#science_portal_member_ids_field', user.profile.name)

        click_button("Save")
        page.should have_content('Science portal successfully created')
        SciencePortal.find_by_slug(slug).check_access(user.profile.id).should be_true

      end

      as_user user do
        visit science_portal_path(id: slug )
        expect(page).to have_html(desc)
        expect(page).to have_css('h1', :text => name)

        within('#leaders') do
          page.should have_content(leader.profile.name)
        end
      end
    end

    scenario "Create Basic public Page with links", :js => true  do
      as_user Fabricate(:admin)
      slug = "test_portal_1"
      name = "Test Protal Title"
      desc = Faker::Lorem.paragraph(5)
      link_name = "new link name"
      link_url = Faker::Internet.url
      visit rails_admin.new_path(model_name: 'science_portal')

      fill_in('Slug', with: slug)
      fill_in('Name', with: name)
      fill_in_ckeditor('#cke_1_contents', desc)
      check('Public')
      click_on('Add a new Science link')
      within('#science_portal_science_links_attributes_field') do
        fill_in('Name', with: link_name)
        fill_in('Url', with: link_url)
      end

      click_button("Save")

      visit science_portal_path(id: slug )
      expect(page).to have_html(desc)
      expect(page).to have_css('h1', :text => name)

      within('#links') do
        page.should have_link(link_name, href: link_url)
      end

    end

  end
=end
  describe "edit protal in admin interface" do
    scenario "edit desc", :js => true do
      sp = Fabricate(:science_portal).reload
      as_user Fabricate(:admin)
      visit rails_admin.index_path(model_name: 'science_portal')
      page.should have_content sp.name
      click_link
    end
  end
end
