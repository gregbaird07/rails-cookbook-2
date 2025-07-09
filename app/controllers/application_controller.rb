class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  # Redirect to home page after successful sign in
  def after_sign_in_path_for(resource)
    Rails.logger.info "=== AFTER SIGN IN: Redirecting user #{resource.email} to #{root_path} ==="
    root_path
  end
  
  # Add logging for sign out as well
  def after_sign_out_path_for(resource_or_scope)
    Rails.logger.info "=== AFTER SIGN OUT: Redirecting to #{root_path} ==="
    root_path
  end
end
