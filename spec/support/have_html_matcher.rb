require 'rspec/expectations'
RSpec::Matchers.define :have_html do |contains|
  match do |page|
    !page.html.index(contains).nil?
  end
end