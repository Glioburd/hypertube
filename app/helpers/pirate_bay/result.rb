module PirateBay
  class Result
    attr_accessor :name, :seeds, :leeches, :magnet_link

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
    end
  end
end
