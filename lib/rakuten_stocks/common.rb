module RakutenStocks
  module Common
    def toencode(encode, content)
      case encode.downcase
      when 'UTF-8'.downcase then
        return content.toutf8
      when 'EUC-JP'.downcase then
        return content.toeuc
      end    
    end

    def xpath_children(node, xpath)
      node.xpath(xpath).children.to_s
    end

    def xpath_to_f(node, xpath)
      xpath_children(node, xpath).strip.gsub(',', '').gsub('%', '').to_f
    end

    def xpath_to_i(node, xpath)
      xpath_children(node, xpath).strip.gsub(',', '').to_i
    end

    module_function :toencode
    module_function :xpath_children
    module_function :xpath_to_f
    module_function :xpath_to_i
  end
end