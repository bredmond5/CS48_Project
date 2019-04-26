
from urllib.request import urlopen as ureq 	#use this one if you're running it as python3 priceScrape.py
from bs4 import BeautifulSoup as soup

groceryUrlBeginning = "https://www.mygrocerydeals.com/deals?utf8=%E2%9C%93&authenticity_token=KFo1qPeErMj0RspD%2F8AhWJlc9BChi8x8L6irKF9pfCDTL4%2B7TkK0EgkeC85l933qffsBAuiYEHhOFgqQUy0nJg%3D%3D&remove%5B%5D=chains&remove%5B%5D=categories&remove%5B%5D=collection&remove%5B%5D=collection_id&q="
groceryUrlEnd = "&supplied_location=93107&latitude=34.42&longitude=-119.69999999999999"
walmartUrlBeginning = "https://www.walmart.com/search/?cat_id=0&query="
targetUrlBeginning = "https://www.target.com/s?searchTerm="
amazonUrlBeginning = "https://www.amazon.com/s?k="


product = input("Please enter the product: ")
fileName = product.title().replace(" ", "") + ".csv"
product = product.replace(" ", "+")

# upci = input("UPCI: ")


f = open(fileName, "w")						#opens file for writing
f.write("Product Name" + ";" + "Size/Count" + ";" + "Price" + ";" + "Deal End" + ";" + "Store Name" + "\n") #setting headers of csv file

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
	size = sizeContainer[0].text

	priceContainer = container.findAll("span", {"class":"pricetag"})				#Finding Price
	price = priceContainer[0].text

	dealEndContainer = container.findAll("div", {"class":"expirydate"})				#Finding deal end date
	dealEnd = dealEndContainer[0].text

	storeNameContainer = container.findAll("p", {"class":"deal-storename"})			#Finding store of sale
	storeName = storeNameContainer[0].text

	f.write(productName + ";" + size + ";" + price + ";" + dealEnd + ";" + storeName + "\n")
	count+=1

###################################################################################################################################################














###########################################################Searches target.com#############################################################

# url = targetUrlBeginning + upci 	#page URL
# url = "https://www.target.com/s?searchTerm=Lay%27s+Classic+Potato+Chips+-+8oz"

# uclient = ureq(url) 					#opening connection to website	
# pageHTMl = uclient.read()				#reading HTML
# uclient.close()
# content = soup(pageHTMl, "html.parser")

# priceContainer = content.findAll("ul", {"data-test":"product-price"})
# if(priceContainer):
# 	price = priceContainer[0].text
# 	print(price)
# else:
# 	print(priceContainer)

f.close() #closes off the file
