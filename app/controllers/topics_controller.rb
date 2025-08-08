class TopicsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'
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
    languages = [
      {lang: 'en', query: 'earthquake', from: 'en', to: 'ja', translate: true},
      {lang: 'ja', query: '地震', translate: false}

    ]
    api_key = ENV["NEWS_API_KEY"]
    request_range = 1..5
    each_article_range = 0..2

    nm = Natto::MeCab.new

  languages.each do |eachlang|
     encoded_query =  ERB::Util.url_encode(eachlang[:query])

    request_range.each do |num|
      news_url = URI("https://api.thenewsapi.com/v1/news/all?api_token=#{api_key}&search=#{encoded_query}&page=#{num}")
      news_response = Net::HTTP.get(news_url)
      news_data = JSON.parse(news_response)

      each_article_range.each do |enum|
       article = news_data["data"][enum]
       next unless article

       text = article["title"]
 
       translated_title = if eachlang[:translate]
         encoded_text = ERB::Util.url_encode(text)
         mymemory_url = URI("https://api.mymemory.translated.net/get?q=#{encoded_text}&langpair=#{eachlang[:from]}|#{eachlang[:to]}")
         mymemory_response = Net::HTTP.get(mymemory_url)
         mymemory_data = JSON.parse(mymemory_response)
         mymemory_data["matches"][0]["translation"]
       else
         text
       end



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
end


   

    def topic_params
      params.require(:topic).permit(:title, :description, :url, :image_url, :latitude, :longitude, :published_at)
    end

end