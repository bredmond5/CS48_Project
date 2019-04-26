import urllib.request
from bs4 import BeautifulSoup




url = "https://www.amazon.com/s?k=lays+potato+chips&crid=2T1H5WVGP7K6A&sprefix=lays%2Caps%2C199&ref=nb_sb_ss_i_1_4"

headers = {
    'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36'
}




req = urllib.request.Request(url, headers=headers)
response = urllib.request.urlopen(req)
pageHTML = response.read()
response.close()

soup = BeautifulSoup(pageHTML, "html.parser")
priceContainer1 = soup.findAll("span", {"class":"a-price-whole"})
priceContainer2 = soup.findAll("span", {"class":"a-price-fraction"})
print(priceContainer1)

if(priceContainer1):
	price = priceContainer1[0].text + priceContainer2[0].text
	print(price)
else:
	priceContainer0 = soup.findAll("div", {"class":"sg-col-inner"});
	#price = priceContainer0[0].text
	print(priceContainer0)