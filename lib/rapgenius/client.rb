require 'httparty'

module RapGenius
  module Client
    class << self
      attr_accessor :access_token
    end

    class HTTPClient
      include HTTParty

      format   :json
      base_uri 'https://api.rapgenius.com'
    end

    BASE_URL = HTTPClient.base_uri + "/".freeze
    PLAIN_TEXT_FORMAT = "plain".freeze
    DOM_TEXT_FORMAT = "dom".freeze

    attr_reader :text_format

    def url=(url)
      unless url =~ /^https?:\/\//
        @url = BASE_URL + url.gsub(/^\//, '')
      else
        @url = url
      end
    end

    def document
      @document ||= fetch(@url)
    end

    def fetch(url)
      response = HTTPClient.get(url, query: {
        text_format: "#{DOM_TEXT_FORMAT},#{PLAIN_TEXT_FORMAT}"
      }, headers: {
        'Authorization' => "Bearer #{RapGenius::Client.access_token}",
        'User-Agent' => "rapgenius.rb v#{RapGenius::VERSION}"
      })

      if response.code != 200
        if response.code == 404
          raise RapGenius::NotFoundError
        else
          raise RapGenius::Error, "Received a #{response.code} HTTP response"
        end
      end

      response.parsed_response
    end
  end
end
