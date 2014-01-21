require 'spec_helper'

feature "Profiles" do
  describe "Viewing on website" do
    scenario "index" do
      (1..40).each do |i|
        Fabricate(:user_with_credit, credit: (1000-i*10), rank: i)
      end
      visit profiles_path
      #screenshot_and_open_image
    end
  end
end