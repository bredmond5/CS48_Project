from urllib.request import urlopen as ureq
from bs4 import BeautifulSoup as soup

# url = "https://www.walmart.com/ip/Lay-s-Kettle-Cooked-Potato-Chips-Variety-Snack-Pack-40-Count/564560953"


# uclient = ureq(url) 					#opening connection to website	
# pageHTMl = uclient.read()				#reading HTML
# uclient.close()
# content = soup(pageHTMl, "html.parser")


# price = content.findAll("span", {"class":"price-characteristic"})
# price = price[0]["content"]


# print(price)

url = "https://www.amazon.com/Lays-Potato-Chips-Variety-Count/dp/B07179XBP9/ref=sr_1_3?keywords=lays&qid=1555903458&s=gateway&sr=8-3"

uclient = ureq(url) 					#opening connection to website	
pageHTMl = uclient.read()				#reading HTML
uclient.close()
content = soup(pageHTMl, "html.parser")


price = content.findAll("span", {"id":"priceblock_snsprice_Based"})
price = price[0].span.text


print(price.strip())


