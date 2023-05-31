# Load the gem and specific api model you'd like to use

require 'amz_sp_api'
require 'sellers-api-model'
require 'fulfillment-outbound-api-model'
require 'listings-items-api-model'
require 'catalog-items-api-model'
require 'reports-api-model'

  AmzSpApi.configure do |config|
    config.refresh_token =  Rails.application.credentials.lwa[:refresh_token] 
    config.client_id = Rails.application.credentials.lwa[:client_id]
    config.client_secret = Rails.application.credentials.lwa[:client_secret]

    # either use these:
    config.aws_access_key_id = Rails.application.credentials.aws[:access_key_id]
    config.aws_secret_access_key = Rails.application.credentials.aws[:secret_access_key]

    config.region = 'na'
    config.timeout = 20 # seconds
    config.debugging = true
    config.logger = Rails.logger

    # optional lambdas for caching LWA access token instead of requesting it each time, e.g.:
    config.save_access_token = -> (access_token_key, token) do
      Rails.cache.write("SPAPI-TOKEN-#{access_token_key}", token[:access_token], expires_in: token[:expires_in] - 60)
    end
    config.get_access_token = -> (access_token_key) { Rails.cache.read("SPAPI-TOKEN-#{access_token_key}") }

  end




