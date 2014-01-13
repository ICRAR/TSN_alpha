require "spec_helper"

describe SciencePortal do
  it "has a valid Fabricator" do
    new_page = Fabricate(:science_portal, slug: 'Test Page').reload
    new_page.should be_valid
  end
  it "has a valid Fabricator with links" do
    new_page = Fabricate(:science_portal_with_links, slug: 'Test Page').reload
    new_page.should be_valid
  end

  it "should be invalid without a slug" do
    expect{Fabricate(:science_portal, slug: '')}.to be_invalid
  end

  it "should be invalid with duplicate slugs" do
    Fabricate(:science_portal, slug: 'same')
    expect{Fabricate(:science_portal, slug: 'same')}.to be_invalid
  end
end