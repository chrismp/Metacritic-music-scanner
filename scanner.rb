[
	"open-uri",
	"mechanize",
	"csv"
].each{|g|
	require g
}

def openURL(agent,url)
	p "OPENING #{url}"
	return agent.get(url)
end

def textStrip(tag)
	return tag.text.strip
end

csvInfoHash= {
	"Albums" => [
		"AlbumURL",
		"Album",
		"ArtistURL",
		"Label",
		"LabelURL",
		"Summary",
		"Metascore",
		"CriticScores",
		"UserScore",
		"UserScores"
	],
	"Artists" => [
		"Artist",
		"URL"
	],
	"CriticReviews" => [
		"Critic",
		"AlbumURL",
		"Score"
	],
	"Genres" => [
		"Genre",
		"AlbumURL"
	]
}

CSV.open("artists.csv",'w',:write_headers=>true,:headers=>artistsHeaders)


agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

baseURL=		"http://www.metacritic.com"
letterArray=	('a'..'z').map{|x| x}
letterArray.insert(0,'9')
letterArray.each{|ltr|
	pgNum=	0
	loop{  
		albumDirectoryURL=	baseURL+"/browse/albums/release-date/available/date?page="+pgNum.to_s
		albumDirectoryPage=	openURL(agent,albumDirectoryURL)
		listProducts=		albumDirectoryPage.css(".list_products")	# `ol` containing `li` elements containing links to album pages
		if listProducts.length==0
			break
		end

		listProducts.css('a').each{|a|
			albumURL=	baseURL+a["href"]
			albumPage=	openURL(agent,albumURL)
			album=		textStrip(albumPage.css(".product_title")[0])
			artist=		textStrip(albumPage.css(".product_artist a")[0])
			artistHref=	albumPage.css(".product_artist a")[0].attr("href")
			label=		textStrip(albumPage.css(".product_company .data")[0])
			labelHref=	albumPage.css(".publisher a")[0].attr("href")
			genres=		albumPage.css(".product_genre .data").map{|d|
				textStrip(d)
			}
			summary=	textStrip(albumPage.css(".product_summary .data span"))
			metascore=	textStrip(albumPage.css(".metascore_summary span[itemprop='ratingValue']")[0])
			criticScores=textStrip(albumPage.css(".metascore_summary span[itemprop='reviewCount']")[0])
			userScore=	textStrip(albumPage.css(".userscore_wrap div.user")[0])
			userScore=	userScore == "tbd" ? nil : userScore
			userScores=	nil
			if userScore != nil
				userScores=	textStrip(albumPage.css(".userscore_wrap .count a")[0]).gsub(" Ratings",'')	
			end
			
			p album,artist,artistHref,label,labelHref,genres,summary,metascore,criticScores,userScore,userScores,"=="

			criticsURL=	albumURL+"/critic-reviews"
			criticsPage=openURL(agent,criticsURL)
			criticsPage.css(".critic_review").each{|reviewTag|
				critic=		textStrip(reviewTag.css(".source")[0])
				reviewDate=	textStrip(reviewTag.css(".date")[0])
				criticScore=textStrip(reviewTag.css(".review_grade")[0])
				p critic,reviewDate,criticScore
				p "==="
			}
		}
		p "========"
		pgNum+=1
	}
}