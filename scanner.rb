[
	"open-uri",
	"mechanize",
	"csv"
].each{|g|
	require g
}

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"


baseURL=		"http://www.metacritic.com"
letterArray=	('a'..'z').map{|x| x}
letterArray.insert(0,'9')
letterArray.each{|ltr|
	pgNum=	0
	loop{  
		albumDirectoryURL=	baseURL+"/browse/albums/artist/"+ltr+"?page="+pgNum.to_s
		p "OPENING #{albumDirectoryURL}"
		albumDirectoryPage=	agent.get(albumDirectoryURL)
		listProducts=		albumDirectoryPage.css(".list_products")	# `ol` containing `li` elements containing links to album pages
		if listProducts.length==0
			pgNum=	0
			break
		end
		listProducts.css('a').each{|a|
			albumURL=	baseURL+a["href"]
			albumPage=	agent.get(albumPage)
		}
		p "========"
		pgNum+=1
	}
}