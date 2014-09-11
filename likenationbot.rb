require 'bundler'
Bundler.require

require_relative 'config'

require 'logger'


# TODO cleanup after all of that coding...
# Fun TODO: log/collect information on other YT entries =)
# TODO logging and reliability...


# meh...
log = nil
headless = nil
d = nil


def initLogger
	log = Logger.new('inf.log','daily')
	log.level = Logger::INFO
	log.info "Started Bot"
end


def initWebdriver(hless,ffpath)
	if(hless)
		headless = Headless.new
		headless.start
	end

	#profile = Selenium::WebDriver::Firefox::Profile.new
	#profile["browser.shell.checkDefaultBrowser"] = false
	#profile["media.volume_scale"] = 0.0 # Mute those vids...

	if(!ffpath.empty?)
		Selenium::WebDriver::Firefox.path = ffpath
	end

	begin
		d = Selenium::WebDriver.for :firefox
		#d = Selenium::WebDriver.for :firefox, :profile => profile
	rescue Selenium::WebDriver::Error::WebDriverError
		# THIS FUCKING ERROR IS DRIVING ME CRAZY AAAAAAAAAAAAa sdmfveswajnc5tgyu4anw
		# FUCKING TIMEOUTS NO MATTER WHAT I DO
		# sigh~...
		log.fatal 'WebDriverError -> unable to obtain stable firefox connection in 60 seconds'
		abort
	end
end

# aux method
def wait_for(driver, css_selector)
	wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
	wait.until { driver.find_element(:css => css_selector) }
end

def requestHTML5
	# switch to html5 player on YT to make life easier
	#puts 'Requesting HTML5 Player...'
	#d.navigate.to "https://www.youtube.com/html5"
	#d.find_element(:css => 'button.yt-uix-button.yt-uix-button-size-xlarge.yt-uix-button-primary').click
	#wait_for(d,'button.yt-uix-button.yt-uix-button-size-xlarge.yt-uix-button-dark') #yuck...
end

def login(name,pass)
	# login
	d.navigate.to "http://likenation.com/"
	log.info 'Logging in...'
	d.find_element(:css => 'input.login.login_user').send_keys(name)
	d.find_element(:css => 'input.login.login_password').send_keys(pass)
	d.find_element(:css => 'input.buy_but').click
	wait_for(d,'div.earn_menu')
	log.info 'Successfully Logged in =)'
end

def viewVids()
	# youtube views...
	log.info 'Watching YT Vids for Points...'
	d.navigate.to "http://likenation.com/p.php?p=youtube"
	# TODO put some asserts, timeouts on waits, rescues... =)
	vidCount = 0
	pointCount = 0
	while(true) do
		if(d.find_elements(:css => "div.error").size > 0)
			#'no more points' / limit reached?
			log.warn 'No more Watches Available, Finishing...'
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
			log.warn 'JavascriptError, Failed Starting YT Vid, Retrying...'
			sleep(5) # improve this...
			tryCount += 1
			if tryCount > 3
				log.warn 'Skipping Vid...'
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
		log.info "#{vidCount}: Watched a Video for #{points_earned} for a total of #{pointCount} points."
	end
end

def cleanup()
	d.quit
	headless.destroy if(hless)
	log.info 'Done ^_^'
end


# ----------

def run
	initLogger
	initWebdriver(Configuration::HLESS,Configuration::FFPATH)

	login(Configuration::NAME,Configuration::PASS)
	viewVids

	cleanup
end


run

