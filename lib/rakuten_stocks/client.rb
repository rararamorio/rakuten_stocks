require 'mechanize'
require 'nokogiri'
require "rakuten_stocks/domestic_stocks"

module RakutenStocks
  class Client
    attr_accessor :user_id, :user_pwd, :encode, :user_agent_alias

    def initialize(user_id, user_pwd, encode='UTF-8', user_agent_alias='Windows Mozilla')
      @user_id = user_id
      @user_pwd = user_pwd
      @encode = encode # utf-8/euc-jp のみ取りあえず対応
      @user_agent_alias = user_agent_alias # 必要に応じてUAは変えてね！

      @url = 'https://www.rakuten-sec.co.jp'
      @member_url = 'https://member.rakuten-sec.co.jp'
      @script = "//script"
    end
    
    # 国内株式一覧
    def domestic_stocks
      result = {}

      contents = rakuten_login('STK_POS')
      
      if contents.nil?
        return {status: false, message: 'login failed.'}
      end

      stocks = DomesticStocks.new(contents, @encode)
      result = {status: true}
      result.merge!(stocks.get)
      result
    end

    # 楽天証券ログイン
    # ログイン後、JavaScriptでロケーションを返すので、その内容を読み取って返す。
    # ログインに失敗した場合は nil を返す。
    def rakuten_login(homeid)
      agent = Mechanize.new
      agent.user_agent_alias = @user_agent_alias

      html = agent.get(@url)
      response = html.form_with(name: 'loginform') do |form|
        form.field_with(name: 'loginid').value = @user_id
        form.field_with(name: 'passwd').value = @user_pwd
        form.field_with(name: 'homeid').value = homeid
      end.submit.content

      contents = Nokogiri::HTML(encode(response), nil, @encode)
      
      script = xpath_children(contents, @script)
      if script.nil?
       return nil
      end

      # ログイン時、JavaScriptのlocation.hrefでメンバーページに遷移しているため、内容を取得後URLを再作成しnokogiriにセットする。
      script.match(/<!--\nlocation.href = \"(.+)\";\n\/\/ -->/) do |location|
        stock_list_url = @member_url + location[1]
        # 保有商品一覧ページのスクレイピングを開始
        return Nokogiri::HTML(encode(agent.get(stock_list_url).content), nil, @encode)
      end
      nil
    end

    # 内部で保持するHTMLの文字コード
    def encode(content)
      case @encode.downcase
      when 'UTF-8'.downcase then
        return content.toutf8
      when 'EUC-JP'.downcase then
        return content.toeuc
      end    
    end

    def xpath_children(node, xpath)
      node.xpath(xpath).children.to_s
    end
  end
end