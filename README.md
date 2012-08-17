# Nightflight

Gmail → Mailgun → Heroku → IFTTT

This tiny app receives emails from yakan-hiko via [Mailgun](http://www.mailgun.com), downloads the epub file and sends it to [IFTTT](https://ifttt.com/) with "#epub #yakanhiko" in the subject for further automation.

I personally setup IFTTT recipe to send it to [Wappwolf](http://wappwolf.com/) dropbox folder to send to Kindle.

# HOWTO

Beware it is complicated.

* Deploy this app to heroku, note the URL
* Create mailgun account and note your API key and domain
* `heroku config:add` environment variables (see below)
* Make a route on mailgun to send to the Heroku app, for example route `nightflight-epub@yourdomain.mailgun.org` to `http://yourapp.herokuapp.com/receive`
* Enable Gmail filter `from:yakan-hiko.com` to `nightflight-epub@yourdomain.mailgun.org`. This application automatically confirms the Gmail forwarding request.

Now every time Yakan-hiko sends your a new issue, epub file attachements are downloaded and sent to `trigger@ifttt.com` with `#epub #yakanhiko` tags. Make a recipe to save it to dropbox or however you want.

# Environment variables

This app is supposed to run on Heroku and requires following environment variables set via `heroku config:add`.

* YAKAN_HIKO_LOGIN - login for yakan-hiko.com
* YAKAN_HIKO_PASSWORD - password
* MAILGUN_API_KEY - Mailgun API Key
* MAILGUN_DOMAIN - your domain for mailgun (sample.mailgun.org)
* EMAIL_FROM - From: header for the email sent. Set it for IFTTT identification

