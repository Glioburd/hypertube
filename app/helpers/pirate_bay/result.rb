module PirateBay
  class Result
    attr_accessor :name, :seeds, :leeches, :magnet_link, :imdb, :language

    def initialize(row = nil)
      magnet_links = row.css("td")[1].css("a[title='Download this torrent using magnet']")
      if magnet_links.size > 0
        magnet_link = magnet_links.first[:href]
      else
        magnet_link = nil
      end
      self.name = row.css(".detName").first.content.strip
      self.seeds = row.css("td")[2].content.to_i
      self.leeches = row.css("td")[3].content.to_i
      self.magnet_link = magnet_link
      self.imdb = ""
      begin
        doc = Nokogiri::HTML(get_search_results(row.css(".detLink").first['href']))
        doc = doc.css('#details').css('.col1')
        doc.css('a').each_with_index do |line|
          if line['href'].include?('imdb')
            self.imdb = line['href'].split('/')[-1]
          end
        end
        doc.css('dt').each_with_index do |line, i|
          if line.to_s.include?('Spoken')
            self.language = doc.css('dd')[i].to_s[4..-6]
          end
        end
      rescue
      end
    end

    def get_search_results(url)
      url = 'https://thepiratebay.org' + url
      open(url, { "User-Agent" => "libcurl-agent/1.0" }).read
    end
  end
end
