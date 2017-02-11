module PirateBay
  class Search
    attr_accessor :search_string, :category_id, :page, :results

    def initialize(search_string)
      self.search_string = URI.encode(search_string)
      self.category_id = 200 #category 200 = movie
      self.page = -1
      @results = []
    end

    def execute
      return nil if search_string.nil?
      self.page += 1
      doc = Nokogiri::HTML(get_search_results)
      next_page(doc)
    end

    def get_search_results
      url = "https://thepiratebay.org/search/#{search_string}/#{page}/7/#{category_id}" # highest seeded first
      open(url, { "User-Agent" => "libcurl-agent/1.0" }).read
    end

    def next_page(doc)
      doc.css("#searchResult tr").each_with_index do |row, index|
        next if (index == 0)
        next if (row.css("td").size <= 1)
        next if (index > 5)
        result = PirateBay::Result.new(row)
        @results << result
      end
      @results
    end
  end
end
