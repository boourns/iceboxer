require 'active_support/all'
require 'byebug'
require 'httparty'

module Iceboxer
  class ProductPains

    def self.create_issue(issue, github_url, product_id)
      uri = 'https://productpains.com/api/createPost'
      headers = {'Cookie' => ENV['PRODUCT_PAINS_COOKIE']}
      data = {
        product: {'_id' => product_id}.to_json,
        title: issue.title,
        tags: [].to_json,
        feedback: "Moved from #{github_url}",
        imageURLs: [].to_json
      }

      result = JSON.parse(HTTParty.post(uri, {body: data, headers: headers}))
      "https://productpains.com/post/react-native/#{result['post']['urlName']}"
    end

  end
end
