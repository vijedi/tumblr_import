require 'sinatra'
require 'nokogiri'
require 'oauth'
require 'yaml'
require 'rest_client'

enable :sessions

CONFIG = YAML.load_file("tumblr_import.yml")
TUMBLR_POST_URL = "http://api.tumblr.com/v2/blog/#{CONFIG['base_hostname']}/post"

get '/oauth_callback' do
    request_token = session[:request_token]
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    import_wp_blog(access_token)
    'Import Complete'
end

get '/start' do
    consumer = OAuth::Consumer.new(CONFIG['oauth_key'], CONFIG['oauth_secret'],
                               { :site               => "http://www.tumblr.com",
                                 :http_method        => :post,
                                 :request_token_path => "/oauth/request_token",
                                 :authorize_path  => "/oauth/authorize",
                                 :access_token_path     => "/oauth/access_token",
                               })
    request_token = consumer.get_request_token({:oauth_callback => CONFIG['oauth_callback_url']})
    session[:request_token] = request_token
    redirect to(request_token.authorize_url(:oauth_callback => CONFIG['oauth_callback_url']))
end

def post_to_tumblr(access_token, wp_post)
    params = {
        :type => 'text',
        :state => 'published',
        :tweet => 'off',
        :date => wp_post[:date],
        :body => wp_post[:body]
    }

    unless wp_post[:tags].empty?
        params[:tags] = wp_post[:tags]
    end

    unless wp_post[:title].empty?
        params[:title] = wp_post[:title]
    end

    tumblr_post = access_token.post(TUMBLR_POST_URL, params)
end

def import_wp_blog(access_token)
    doc = Nokogiri::XML(File.open(CONFIG['wp_file']))
    doc.xpath('//item').each do |node|
        # Check if post is supposed to be published - these are the ones we want
        if node.at_xpath('./wp:status').content == "publish" 
            wp_post = {}
            wp_post[:title] = node.at_xpath('./title').content
            pubDateStr = node.at_xpath('./pubDate').content
            wp_post[:date] = (Time.parse(pubDateStr).utc).to_s
            wp_post[:body] = node.at_xpath('./content:encoded').content
            # Now we work the tags
            tags = []
            node.xpath('./category').each do |category|
                if category.attributes['domain'] == 'tag' and category.attributes['nicename'] != nil
                    tags << category.attributes['nicename']
                end
            end

            wp_post[:tags] = tags.join(',')
            # IMPORTANT line, actually publishes to Tumblr. Comment it if you want to dry run.
            tumblr_post = post_to_tumblr(access_token, wp_post)
            puts "Tumblr: " + tumblr_post.to_s
        end
    end
end