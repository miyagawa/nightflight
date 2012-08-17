# Receives yakan-hiko email forwarded, download the epub, send it to trigger@ifttt.com
# with .epub as an attachment

require 'sinatra'
require 'faraday'
require 'mechanize'

class Agent
  def initialize(login, password)
    @agent = Mechanize.new
    @agent.pluggable_parser['application/epub+zip'] = Mechanize::Download
    @login, @password = login, password
  end

  def handle_confirmation(text)
    url = text.match(%r[https://isolated\.mail\.google\.com/mail/\S+])[0]
    @agent.get url
  end

  def handle_epub(text)
    if url = find text
      file = download url
      send file
    end
  end

  def find(text)
    match = text.match(%r|http://yakan-hiko\.com/EPUB\d+|)
    match[0] if match
  end

  def download(url)
    page = @agent.get 'https://yakan-hiko.com/login.php'
    form = page.form_with(:name => 'contact')
    form.login_id = @login
    form.pass = @password
    @agent.submit form
    @agent.get(url)
  end

  def send(page)
    send_email(
      :from => ENV['EMAIL_FROM'],
      :to => "trigger@ifttt.com",
      :subject => "#epub #yakanhiko #{page.filename}",
      :text => "Attached #{page.filename}",
      :attachment => Faraday::UploadIO.new(page.body_io, page.response['content-type'], page.filename)
    )
  end

  def send_email(params)
    url = "https://api:#{ENV['MAILGUN_API_KEY']}@api.mailgun.net"

    conn = Faraday::new(:url => url) do |builder|
      builder.request :multipart
      builder.request :url_encoded
      builder.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.url "/v2/#{ENV['MAILGUN_DOMAIN']}/messages"
      req.body = params
    end
  end
end

post '/receive' do
  agent = Agent.new(ENV['YAKAN_HIKO_LOGIN'], ENV['YAKAN_HIKO_PASSWORD'])
  if params['subject'].match /Gmail Forwarding Confirmation/
    agent.handle_confirmation(params['stripped-text'])
  else
    agent.handle_epub(params['stripped-text'])
  end
  "OK"
end

get '/' do
  "Forward your yakan-hiko email to Mailgun and route it to #{request.url}receive"
end
