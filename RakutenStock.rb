require 'mechanize'
require 'nokogiri'

class RakutenStock
  attr_accessor :user_id, :user_pwd, :homeid, :encode, :user_agent_alias

  def initialize(user_id, user_pwd, homeid='STK_POS', encode='UTF-8', user_agent_alias='Windows Mozilla')
    @user_id = user_id
    @user_pwd = user_pwd
    @homeid = homeid # 初期値は保有商品一覧
    @encode = encode # utf-8/euc-jp のみ取りあえず対応
    @user_agent_alias = user_agent_alias # 必要に応じてUAは変えてね！

    @url = 'https://www.rakuten-sec.co.jp'
    @member_url = 'https://member.rakuten-sec.co.jp'
    @script = "//script"
  end
  
  def get_stocks
    result = {}
    agent = Mechanize.new
    agent.user_agent_alias = @user_agent_alias
    contents = rakuten_login(agent)
    
    # TODO: ログイン失敗の処理を追加
    if contents.nil?
      return 'ログイン失敗'
    end

    # 時価評価額合計/評価損益額合計
    result.merge!(parse_total(contents))
    # 普通口座/特定口座/NISA口座の保有株一覧取得
    result.merge!(parse_stock(contents))
    result
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
  
  # 楽天証券ログイン
  # ログイン後、JavaScriptでロケーションを返すので、その内容を読み取って返す。
  # ログインに失敗した場合は nil を返す。
  def rakuten_login(agent)
    html = agent.get(@url)
    response = html.form_with(name: 'loginform') do |form|
      form.field_with(name: 'loginid').value = @user_id
      form.field_with(name: 'passwd').value = @user_pwd
      form.field_with(name: 'homeid').value = @homeid
    end.submit.content

    contents = Nokogiri::HTML(encode(response), nil, @encode)
    
    script = xpath_children(contents, @script)
    if script.nil?
     return nil
    end

    # ログイン時、JavaScriptのlocation.hrefでメンバーページに遷移しているため、内容を取得後URLを再作成しnokogiriにセットする。
    stock_list_url = @member_url + script.match(/<!--\nlocation.href = \"(.+)\";\n\/\/ -->/)[1]
    # 保有商品一覧ページのスクレイピングを開始
    Nokogiri::HTML(encode(agent.get(stock_list_url).content), nil, @encode)
  end
  
  def xpath_to_f(node, xpath)
    xpath_children(node, xpath).strip.gsub(',', '').gsub('%', '').to_f
  end

  def xpath_to_i(node, xpath)
    xpath_children(node, xpath).strip.gsub(',', '').to_i
  end

  def xpath_children(node, xpath)
    node.xpath(xpath).children.to_s
  end

  # 時価評価額合計/評価損益額合計
  def parse_total(node)
    result = {}
    result[:appraisal_price_data] = xpath_to_i(node, "//div[@id='totalAppraisalPriceData']/nobr")
    result[:profit_loss_data] = xpath_to_i(node, "//div[@id='totalProfitLossData']/nobr")
    {total: result}
  end

  # 口座の内容取得パーサー
  def parse_stock(contents)
    result = {}
    # 保有株の一覧を取得
    # 普通口座も入る可能性があるため、テーブルは流動的に取得する
    account_kind = {}
    contents.xpath("//div[@class='caption']/h2[@class='hdg-l1-01-possess']/span").each_with_index do |node, idx|
      account_kind[ idx + 1 ] = node.children.to_s
    end

    account_kind.each do |key, value|
      case value
      when '特定口座'.encode!(@encode) then
        result.merge!(parse_sp(key, contents))
      when 'NISA口座'.encode!(@encode) then
        result.merge!(parse_nisa(key, contents))
      end
    end
    result
  end

  # 特定口座用のパーサー
  def parse_sp(key, table)
    result = {}
    # 特定口座
    sp = table.xpath("//table[@class='tbl-data-01'][#{key}]")
    sp.xpath("tr[@align='right']").each_with_index do |node, idx|
      stock = {}
      # 銘柄コード
      stock[:code] = xpath_children(node, 'td[2]/div/nobr')
      # 銘柄名
      stock[:name] = xpath_children(node, 'td[3]/div/a')
      # 銘柄名(URL)
      stock[:url] = xpath_children(node, 'td[3]/div/a/@href')
      # 貸株金利
      stock[:loan_stock] = xpath_to_f(node, 'td[6]/div/nobr')
      # 保有数量
      stock[:amount] = xpath_to_i(node, 'td[7]/div/nobr')
      # 平均取得価格
      stock[:acquisition_price] = xpath_to_f(node, 'td[8]/div/nobr')
      # 現在値
      stock[:unit_price] = xpath_to_f(node, 'td[9]/div/nobr')
      # 時価評価額
      stock[:market_value] = xpath_to_f(node, 'td[10]/div/nobr')
      # 評価損益
      stock[:unrealized_profits_and_loses] = xpath_to_f(node, 'td[11]/div[1]/nobr/span')
      # 評価損益率
      stock[:unrealized_profits_and_loses_rate] = xpath_to_f(node, 'td[11]/div[2]/nobr/span')

      result[stock[:code]] = stock
    end
    {sp: result}
  end

  # NISA口座用のパーサー
  def parse_nisa(key, table)
    result = {}
    nisa = table.xpath("//table[@class='tbl-data-01'][#{key}]")
    nisa.xpath("tr[@align='right']").each_with_index do |node, idx|
      stock = {}
      # 銘柄コード
      stock[:code] = xpath_children(node, 'td[2]/div/nobr')
      # 銘柄名
      stock[:name] = xpath_children(node, 'td[3]/div/a')
      # 銘柄名(URL)
      stock[:url] = xpath_children(node, 'td[3]/div/a/@href')
      # 保有数量
      stock[:amount] = xpath_to_i(node, 'td[4]/div/nobr')
      # 平均取得価格
      stock[:acquisition_price] = xpath_to_f(node, 'td[5]/div/nobr')
      # 現在値
      stock[:unit_price] = xpath_to_f(node, 'td[6]/div/nobr')
      # 時価評価額
      stock[:market_value] = xpath_to_f(node, 'td[7]/div/nobr')
      # 評価損益
      stock[:unrealized_profits_and_loses] = xpath_to_f(node, 'td[8]/div[1]/nobr/span')
      # 評価損益率
      stock[:unrealized_profits_and_loses_rate] = xpath_to_f(node, 'td[8]/div[2]/nobr/span')

      result[stock[:code]] = stock
    end
    {nisa: result}
  end
end