require 'rspec/expectations'
RSpec::Matchers.define :be_invalid do
  match do |thing|
    expect(thing).to raise_error(ActiveRecord::RecordInvalid)
  end
end