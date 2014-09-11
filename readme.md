
Likenation Bot
===

Ruby script which views youtube videos on likenation.com for points. Points can be spent later.

Bot is designed to resemble human using a real firefox instance in the background.

Watches until no more videos available or limit reached.

This script is to be used for research purposes only.

/ ZirconCode

Use
---

Clone Repo. Edit `config.rb`.

`sudo apt-get install xvfb` for Headless gem.

`bundle install`

`bundle exec ruby likenationbot.rb`


Bugs
---

Currently sound is still enabled. My attempts at disabling it have run into a bug which I currently don't have the time to trace down (https://github.com/leonid-shevtsov/headless/issues/45). This is not a problem for me as the bot runs on a mute server.

ToDo
---

See comments in likenationbot.rb
