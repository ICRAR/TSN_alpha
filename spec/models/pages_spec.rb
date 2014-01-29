require "spec_helper"

describe Page do
  it "has a valid Fabricator" do
    new_page = Fabricate(:page, slug: 'Test Page').reload
    new_page.should be_valid
  end

  it "should be invalid without a slug" do
    expect{Fabricate(:page, slug: '')}.to be_invalid
  end

  it "should be invvalid with duplicate slugs" do
    Fabricate(:page, slug: 'same')
    expect{Fabricate(:page, slug: 'same')}.to be_invalid
  end
end