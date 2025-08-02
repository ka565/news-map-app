class TopicsController < ApplicationController
  require 'natto'

  def index
    @topics = Topic.all
  end

  def new 
    @topic = Topic.new
  end

  def fetch_and_save
    fetch_articles_and_save
    redirect_to topics_path,notice: "ニュースを更新しました"
  end

  private




  def fetch_articles_and_save
    query = "shark AND found"
    encoded_query =  ERB::Util.url_encode(query)
    api_key =  "MnXHZmDbpMQ7LRRugEJLJ1mvVu9NZ8PDEUbqpr69"

    request_range = 1..5
    each_article_range = 0..2

    nm = Natto::MeCab.new

    request_range.each do |num|
     news_url = URI("https://api.thenewsapi.com/v1/news/all?api_token=#{api_key}&search=#{encoded_query}&page=#{num}")
     news_response = Net::HTTP.get(news_url)
     news_data = JSON.parse(news_response)

     each_article_range.each do |enum|
      article = news_data["data"][enum]
      next unless article

      trans_url = URI("https://libretranslate.com/translate")
      trans_response = Net::HTTP.post(
      trans_url,
      {
        q: article["title"],
        source: "en",
        target: "ja",
        format: "text",
       }.to_json,
      "Content-Type" => "application/json"
       )

      puts "status: #{trans_response.code}"
      puts "Translation response body: #{trans_response.body.inspect}"
      json = JSON.parse(trans_response.body)
      translated_title = json["translatedText"]

      

      location_name = nil
      nm.parse(translated_title) do |n|
       if n.feature.split(",")[2] == "地域"
           location_name = n.surface
           break
       end
      end

     next unless location_name

     encoded_locale = ERB::Util.url_encode(location_name)
     nominatim_url = URI("https://nominatim.openstreetmap.org/search?q=#{encoded_locale}&format=json&limit=1")

     http = Net::HTTP.new(nominatim_url.host, nominatim_url.port)
     http.use_ssl = true
     request = Net::HTTP::Get.new(nominatim_url)
     request["User-Agent"] = "fishnewsmap/1.0 (yuta2004328@outlook.jp)" 
     nominatim_response = http.request(request).body

     nominatim_data = JSON.parse(nominatim_response)

     next unless nominatim_data.any?

     latitude = nominatim_data[0]["lat"].to_f
     longitude = nominatim_data[0]["lon"].to_f

     Topic.create(
      title: translated_title,
      url: article["url"],
      latitude: latitude,
      longitude: longitude
            ) 
            
        sleep(1)
     end
    end
  end
 
    

    def topic_params
      params.require(:topic).permit(:title, :description, :url, :image_url, :latitude, :longitude, :published_at)
    end

end



