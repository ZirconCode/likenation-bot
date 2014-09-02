require 'bundler'
require 'selenium-webdriver'
require 'headless'

# load config
require_relative 'config'
name 	= Configuration::NAME
pass 	= Configuration::PASS
hless	= Configuration::HLESS
# --

# TODO cleanup after all of that coding...
# Fun TODO: log/collect information on other YT entries =)
# TODO logging and reliability...

if(hless)
	headless = Headless.new
	headless.start
end
# TODO bug @ https://github.com/leonid-shevtsov/headless/issues/45
#profile = Selenium::WebDriver::Firefox::Profile.new
#profile["media.volume_scale"] = 0.0 # Mute those vids...
#d = Selenium::WebDriver.for :firefox, :profile => profile
d = Selenium::WebDriver.for :firefox

def wait_for(driver, css_selector)
	wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
	wait.until { driver.find_element(:css => css_selector) }
end

# switch to html5 player on YT to make life easier
#puts 'Requesting HTML5 Player...'
#d.navigate.to "https://www.youtube.com/html5"
#d.find_element(:css => 'button.yt-uix-button.yt-uix-button-size-xlarge.yt-uix-button-primary').click
#wait_for(d,'button.yt-uix-button.yt-uix-button-size-xlarge.yt-uix-button-dark') #yuck...

# login
d.navigate.to "http://likenation.com/"
puts 'Logging in...'
d.find_element(:css => 'input.login.login_user').send_keys name
d.find_element(:css => 'input.login.login_password').send_keys(pass)
d.find_element(:css => 'input.buy_but').click
wait_for(d,'div.earn_menu')
puts 'Successfully Logged in =)'

# youtube views...
puts 'Watching YT Vids for Points...'
d.navigate.to "http://likenation.com/p.php?p=youtube"
# TODO put some asserts, timeouts on waits, rescues... =)
vidCount = 0
pointCount = 0
while(true) do
	if(d.find_elements(:css => "div.error").size > 0)
		#'no more points' / limit reached?
		puts 'No more Watches Availale, Finishing...'
		break
	end
	
	wait_for(d,'a.followbutton')
	d.find_element(:css => "a.followbutton").click
	wait_for(d,'object#myytplayer')
	# player api should be 'ytplayer'
	sleep(5) # improve this...
	tryCount = 0
	begin
		d.execute_script("ytplayer.playVideo();")
	rescue Selenium::WebDriver::Error::JavascriptError
		puts 'JavascriptError, Failed Starting YT Vid, Retrying...'
		sleep(5) # improve this...
		tryCount += 1
		if tryCount > 3
			puts 'Skipping Vid...'
			d.find_element(:link => "skip").click
			next
		else
			retry
		end
	end
	points_earned = d.find_element(:css => "b#n_coins").text.to_i
	sleep (1) while(d.find_element(:css => "span#played").text.to_i < 15)
	wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
	wait.until { d.find_element(:link => 'Click here to watch other movie') }.click
	vidCount += 1
	pointCount += points_earned
	puts "#{vidCount}: Watched a Video for #{points_earned} for a total of #{pointCount} points."
end

d.quit
headless.destroy if(hless)
puts 'Done ^_^'


