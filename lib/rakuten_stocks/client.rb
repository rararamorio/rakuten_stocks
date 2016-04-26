require "rakuten_stocks/version"
require "rakuten_stocks/common"
require "rakuten_stocks/stock"
require "rakuten_stocks/domestic_stocks"
require "rakuten_stocks/http"
require 'mechanize'
require 'nokogiri'


include RakutenStocks::Common

module RakutenStocks
  class Client
    attr_accessor :id, :pwd, :encode, :user_agent_alias

    def initialize
      yield(self) if block_given?
      @http = Http.new do |config|
        config.id = @id
        config.pwd = @pwd
        config.encode = @encode
        config.user_agent_alias = @user_agent_alias
      end
    end
    
    def domestic_stocks
      DomesticStocks.new(@http).get
    end

    def user_agent
      "RakutenStocksGem/#{RakutenStocks::VERSION}"
    end
  end
end