module HttpAuthConcern
  extend ActiveSupport::Concern

  included do
    if ENV["BASIC_AUTH_ENABLED"].present?
      http_basic_authenticate_with(
        name: ENV.fetch("BASIC_AUTH_USERNAME"),
        password: ENV.fetch("BASIC_AUTH_PASSWORD")
      )
    end
  end
end
