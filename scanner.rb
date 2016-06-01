[
	"open-uri",
	"mechanize",
	"csv"
].each{|g|
	require g
}

def openURL(agent,url)
	p "OPENING #{url}"
	begin
		page=	agent.get(url)
	rescue Exception => e
		p "ERROR: #{e}"
		if e.to_s.include?"404"
			return 404			
		end
		sleep 60
		retry
	end
	return page
end

def textStrip(tag)
	return tag===nil ? nil : tag.text.strip
end

albumsCSV=	"Albums.csv"
artistsCSV=	"Artists.csv"
criticsCSV=	"CriticReviews.csv"
genresCSV=	"Genres.csv"
csvInfoHash= {
	albumsCSV => [
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
	artistsCSV => [
		"Artist",
		"URL"
	],
	criticsCSV => [
		"Critic",
		"AlbumURL",
		"Date",
		"Score"
	],
	genresCSV => [
		"Genre",
		"AlbumURL"
	]
}

csvInfoHash.each{|fileName,headersArray|
	if File.exist?(fileName)!=true
		CSV.open(fileName,'w') do |csv|
			csv << headersArray
		end		
	end
}

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

baseURL=		"http://www.metacritic.com"
pgNum=			0
loop{  
	albumDirectoryURL=	baseURL+"/browse/albums/release-date/available/date?page="+pgNum.to_s
	albumDirectoryPage=	openURL(agent,albumDirectoryURL)
	listProducts=		albumDirectoryPage.css(".list_products")	# `ol` containing `li` elements containing links to album pages
	if listProducts.length==0
		break
	end

	listProducts.css('a').each{|a|
		albumURL=	baseURL+a["href"]
		next if openURL(agent,albumURL)===404

		albumPage=	openURL(agent,albumURL)
		album=		textStrip(albumPage.css(".product_title")[0])
		artist=		textStrip(albumPage.css(".product_artist a")[0])
		artistHref=	albumPage.css(".product_artist a")[0].attr("href")
		label=		textStrip(albumPage.css(".product_company .data")[0])
		labelHref=	albumPage.css(".publisher a")[0].attr("href")
		summary=	textStrip(albumPage.css(".product_summary .data span"))
		metascore=	textStrip(albumPage.css(".metascore_summary span[itemprop='ratingValue']")[0])
		criticScores=textStrip(albumPage.css(".metascore_summary span[itemprop='reviewCount']")[0])
		userScore=	textStrip(albumPage.css(".userscore_wrap div.user")[0])
		userScore=	userScore == "tbd" ? nil : userScore
		userScores=	nil
		if userScore != nil
			userScores=	textStrip(albumPage.css(".userscore_wrap .count a")[0]).gsub(" Ratings",'')	
		end

		CSV.open(albumsCSV,'a') do |csv|
			csv << [
				a["href"],
				album,
				artistHref,
				label,
				labelHref,
				summary,
				metascore,
				criticScores,
				userScore,
				userScores
			]
		end
		CSV.open(artistsCSV,'a') do |csv|
			csv << [
				artist,
				artistHref
			]
		end
		albumPage.css(".product_genre .data").each{|genre|
			CSV.open(genresCSV,'a') do |csv|
				csv << [
					genre,
					a["href"]
				]
			end
		}
		
		p album,artist,artistHref,label,labelHref,summary,metascore,criticScores,userScore,userScores,"=="

		criticsURL=	albumURL+"/critic-reviews"
		next if openURL(agent,criticsURL)===404
		criticsPage=openURL(agent,criticsURL)
		criticsPage.css(".critic_review").each{|reviewTag|
			critic=		textStrip(reviewTag.css(".source")[0])
			reviewDate=	textStrip(reviewTag.css(".date")[0])
			criticScore=textStrip(reviewTag.css(".review_grade")[0])
			CSV.open(criticsCSV,'a') do |csv|
				csv << [
					critic,
					a["href"],
					reviewDate,
					criticScore
				]
			end
			p critic,reviewDate,criticScore
			p "==="
		}
	}
	p "========"
	pgNum+=1
}
# }