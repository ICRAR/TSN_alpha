require 'rspec/expectations'
RSpec::Matchers.define :appear_before do |expected|
  match do |actual|
    begin
      page.text.index(actual) < page.text.index(expected)
    rescue ArgumentError
      raise "Could not locate later content on page: #{expected}"
    rescue NoMethodError
      raise "Could not locate earlier content on page: #{actual}"
    end
  end
end