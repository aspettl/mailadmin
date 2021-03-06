# frozen_string_literal: true

json.domains @domains do |domain|
  json.merge! domain
end
json.accounts @accounts do |account|
  json.merge! account
end
