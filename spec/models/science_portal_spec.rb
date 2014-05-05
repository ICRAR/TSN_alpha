require "spec_helper"

describe SciencePortal do
  it "has a valid Fabricator" do
    sp = Fabricate(:science_portal).reload
    sp.should be_valid
  end
  it "has a valid Fabricator with links" do
    sp = Fabricate(:science_portal_with_links).reload
    sp.should be_valid
  end

  it "should be invalid without a slug" do
    expect{Fabricate(:science_portal, slug: '')}.to be_invalid
  end

  it "should be invalid with duplicate slugs" do
    Fabricate(:science_portal, slug: 'same')
    expect{Fabricate(:science_portal, slug: 'same')}.to be_invalid
  end

  it "should accept leaders" do
    sp = Fabricate(:science_portal).reload
    profile = Fabricate(:user).reload.profile
    sp.leaders << profile
    sp.leaders.should include(profile)
  end

  it "should accept members" do
    sp = Fabricate(:science_portal).reload
    profile = Fabricate(:user).reload.profile
    sp.members << profile
    sp.members.should include(profile)
  end

  it "should respond correctly too check_access()" do
    sp = Fabricate(:science_portal).reload
    profile = Fabricate(:user).reload.profile
    sp.check_access(nil).should be_true
    sp.check_access(profile.id).should be_true

    sp.public = false

    sp.check_access(nil).should be_false
    sp.check_access(profile.id).should be_false

    sp.members << profile
    sp.check_access(profile.id).should be_true

    leader = Fabricate(:user).reload.profile
    sp.check_access(leader.id).should be_false

    sp.leaders << leader
    sp.check_access(leader.id).should be_true

  end

end