module RakutenStocks
  class Http
    attr_accessor :id, :pwd, :encode, :user_agent_alias

    def initialize
      yield(self) if block_given?

      @agent = Mechanize.new
      @agent.user_agent_alias = user_agent_alias

      @url = 'https://www.rakuten-sec.co.jp'
      @member_url = 'https://member.rakuten-sec.co.jp'
    end

    def stk_pos_mode_login
      login?(location(login('STK_POS')))
    end

    def member_contents(path)
      begin
        return Nokogiri::HTML(toencode(@encode, access(@member_url + path).content), nil, @encode)
      rescue
        # login failed!!
      end
      nil
    end

    private

    def login?(contents)
      if contents.nil?
        return {status: false, message: 'login failed.', contents: nil}
      else
        return {status: true, contents: contents}
      end
    end

    # Rakuten Securities Login
    def login(homeid)
      response = access(@url).form_with(name: 'loginform') do |form|
        form.field_with(name: 'loginid').value = @id
        form.field_with(name: 'passwd').value = @pwd
        form.field_with(name: 'homeid').value = homeid
      end.submit.content
      Nokogiri::HTML(toencode(@encode, response), nil, @encode)
    end

    def location(contents)
      script = xpath_children(contents, '//script')
      script.match(/<!--\nlocation.href = \"(.+)\";\n\/\/ -->/) do |location|
        member_contents(location[1])
      end
    end
    
    def access(url)
      @agent.get(url)
    end
  end
end