# frozen_string_literal: true

require 'test_helper'

# Chrome sometimes reports an element that was removed from the page (e.g. by a Turbo page replacement) as
# "unknown error: Node with given id does not belong to the document" instead of a stale element reference.
# Capybara only retries stale element errors, so translate this error to make Capybara retry the query.
module TranslateDetachedNodeError
  private

  def execute(...)
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('Node with given id does not belong to the document')

    raise Selenium::WebDriver::Error::StaleElementReferenceError, e.message
  end
end
Selenium::WebDriver::Remote::Bridge.prepend(TranslateDetachedNodeError)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |option|
    option.add_argument('no-sandbox')
  end
end
