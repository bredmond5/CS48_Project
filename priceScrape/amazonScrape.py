
from urllib.request import urlopen as ureq 	#use this one if you're running it as python3 priceScrape.py
from bs4 import BeautifulSoup as soup
import json

groceryUrlBeginning = "https://www.mygrocerydeals.com/deals?utf8=%E2%9C%93&authenticity_token=KFo1qPeErMj0RspD%2F8AhWJlc9BChi8x8L6irKF9pfCDTL4%2B7TkK0EgkeC85l933qffsBAuiYEHhOFgqQUy0nJg%3D%3D&remove%5B%5D=chains&remove%5B%5D=categories&remove%5B%5D=collection&remove%5B%5D=collection_id&q="
groceryUrlEnd = "&supplied_location=93107&latitude=34.42&longitude=-119.69999999999999"
walmartUrlBeginning = "https://www.walmart.com/search/?cat_id=0&query="
targetUrlBeginning = "https://www.target.com/s?searchTerm="
amazonUrlBeginning = "https://www.amazon.com/s?k="


product = input("Please enter the product: ")
fileName = product.title().replace(" ", "") + ".json"
product = product.replace(" ", "+")

# upci = input("UPCI: ")


############################################################Searches mygrocerydeals.com############################################################


url = groceryUrlBeginning + product + groceryUrlEnd 	#page URL

uclient = ureq(url) 					#opening connection to website	
pageHTMl = uclient.read()				#reading HTML
uclient.close()
content = soup(pageHTMl, "html.parser")

#grabs each product
itemContainers = content.findAll("div", {"data-type":"special"})


count = 0 																			#counter for going row by row
for container in itemContainers:
	productNameContainer = container.findAll("p", {"class":"deal-productname"})		#Finding product name
	productName = productNameContainer[0].text

	sizeContainer = container.findAll("div", {"class":"uom"})						#Finding size/count of product
	size = sizeContainer[0].text.replace(".", "|point|")

	priceContainer = container.findAll("span", {"class":"pricetag"})				#Finding Price
	price = priceContainer[0].text.replace(".", "|point|").replace("$", "|dollars|")

	dealEndContainer = container.findAll("div", {"class":"expirydate"})				#Finding deal end date
	dealEnd = dealEndContainer[0].text.replace("/", "-")

	storeNameContainer = container.findAll("p", {"class":"deal-storename"})			#Finding store of sale
	storeName = storeNameContainer[0].text

	pictureUrlContainer = container.findAll("img", {"class":"deal-productimg"})
	pictureUrl = pictureUrlContainer[0]['src'].replace("$", "|dollars|").replace("#", "|hash|").replace("/", "|slash|").replace(".", "|point|")

	data = {
		"Product name": productName,
		"Size or Count": size,
		"Price": price,
		"Deal End": dealEnd,
		"Store Name": storeName,
		"Picture Url": pictureUrl
	}

	with open(fileName, 'w') as f:
		json.dump(data, f)

	count+=1

