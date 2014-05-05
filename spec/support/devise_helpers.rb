module Helpers

  def as_user(user=nil, &block)
    current_user = user || Fabricate(:user)
    if defined?(request) && request.present?
      sign_in(current_user)
    else
      login_as(current_user, :scope => :user)
    end
    if block.present?
      block.call
      my_logout(current_user)
    end
    return self
  end


  def my_logout(user=nil)
    current_user = user || Fabricate(:user)
    if defined?(request) && request.present?
      sign_out(current_user)
    else
      logout(:user)
    end
    return self
  end
end