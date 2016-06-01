[
	"open-uri",
	"mechanize"
].each{|g|
	require g
}

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

url=					"http://www.metacritic.com/browse/albums/release-date/available"
begin
	page=					agent.get(url)
rescue Exception => e
	p "ERROR: #{e}"
	sleep 60
	retry
end

lastPageNumberTag=		page.css(".page_num")[-1]
lastPageString=			lastPageNumberTag.text.strip
lastPageNumber=			lastPageString.to_i - 1			# Make sure to subtract one since he the page number in the URL is always one less than what is displayed on the page 

puts lastPageNumber