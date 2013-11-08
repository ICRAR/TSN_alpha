module Helpers

  def as_user(user=nil, &block)
    current_user = user || Factory.create(:user)
    if defined?(request) && request.present?
      sign_in(current_user)
    else
      login_as(current_user, :scope => :user)
    end
    block.call if block.present?
    return self
  end


  def as_visitor(user=nil, &block)
    current_user = user || Factory.stub(:user)
    if defined?(request) && request.present?
      sign_out(current_user)
    else
      logout(:user)
    end
    block.call if block.present?
    return self
  end
end