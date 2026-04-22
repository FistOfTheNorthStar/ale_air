# frozen_string_literal: true

module AleAir
  class Error < StandardError; end

  class MissingTokenError < Error; end
  class InvalidTokenError < Error; end
  class ApiError < Error; end
  class NetworkError < Error; end
end
