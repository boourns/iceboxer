require 'active_support/all'
require 'byebug'
require 'httparty'

module Iceboxer
  class Canny

    def self.create_issue(issue, github_url, company_name, board_id)
      uri = "https://#{company_name}.canny.io/api/posts/create"
      headers = {'Cookie' => ENV['CANNY_COOKIE']}
      data = {
        boardID: board_id,
        details: "Moved from #{github_url}",
        title: issue.title,
        imageURLs: [].to_json
      }

      begin
        result = JSON.parse(HTTParty.post(uri, {body: data, headers: headers}))
        "https://#{company_name}.canny.io/#{result['post']['board']['urlName']}/p/#{result['post']['urlName']}"
      rescue JSON::ParserError=>e
        puts "Could not copy over to Canny: " + e.message
        nil
      end
    end

    def self.delete_issue(company_name, post_id)
      unless post_id
        return nil
      end

      uri = "https://#{company_name}.canny.io/api/posts/delete"
      headers = {'Cookie' => ENV['CANNY_COOKIE']}
      data = {
        postID: post_id
      }

      begin
        result = JSON.parse(HTTParty.post(uri, {body: data, headers: headers}))
      rescue JSON::ParserError=>e
        puts "Could not confirm deletion on Canny: " + e.message
      end
    end
  end
end
