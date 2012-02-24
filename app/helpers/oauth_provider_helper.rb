module OauthProviderHelper
  PROVIDERS_ICONS_OPTIONS = {
    facebook: { image: "icons/facebook-icon-48x48.png", size:"48x48", title: "Facebook" },
    google: { image: "icons/g-plus-icon-48x48.png", size: "48x48", title: "Google plus" },
    twitter: { image: "icons/twitter-icon-48x48.png", size: "48x48", title: "Twitter" }
  }
  def provider_button(provider)
    options = PROVIDERS_ICONS_OPTIONS[provider]
    if current_user && current_user.has_provider?(provider)
      image_tag options[:image], size: options[:size], alt: options[:title], class: "grayscale"
    else
      link_to image_tag(options[:image], size: options[:size], alt: options[:title]),
                  user_omniauth_authorize_path(provider),
                  class: 'oauth_btn', title: options[:title]
    end
  end
end
