[
	"open-uri",
	"mechanize",
	"csv"
].each{|g|
	require g
}

def textStrip(tag)
	return tag.text.strip
end


agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"


baseURL=		"http://www.metacritic.com"
letterArray=	('a'..'z').map{|x| x}
letterArray.insert(0,'9')
letterArray.each{|ltr|
	pgNum=	0
	loop{  
		albumDirectoryURL=	baseURL+"/browse/albums/release-date/available/date?page="+pgNum.to_s
		p "OPENING #{albumDirectoryURL}"

		albumDirectoryPage=	agent.get(albumDirectoryURL)
		listProducts=		albumDirectoryPage.css(".list_products")	# `ol` containing `li` elements containing links to album pages
		if listProducts.length==0
			break
		end

		listProducts.css('a').each{|a|
			albumURL=	baseURL+a["href"]
			p "OPENING #{albumURL}"
			albumPage=	agent.get(albumURL)
			album=		textStrip(albumPage.css(".product_title")[0])
			p "=="
		}
		p "========"
		pgNum+=1
	}
}