require "spec_helper"

describe Sub::ShoutBoxesController do
  describe "routing" do

    it "routes to #index" do
      get("/sub/shout_boxes").should route_to("sub/shout_boxes#index")
    end

    it "routes to #new" do
      get("/sub/shout_boxes/new").should route_to("sub/shout_boxes#new")
    end

    it "routes to #show" do
      get("/sub/shout_boxes/1").should route_to("sub/shout_boxes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sub/shout_boxes/1/edit").should route_to("sub/shout_boxes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sub/shout_boxes").should route_to("sub/shout_boxes#create")
    end

    it "routes to #update" do
      put("/sub/shout_boxes/1").should route_to("sub/shout_boxes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sub/shout_boxes/1").should route_to("sub/shout_boxes#destroy", :id => "1")
    end

  end
end
