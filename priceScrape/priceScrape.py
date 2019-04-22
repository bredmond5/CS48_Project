
from urllib.request import urlopen as ureq
from bs4 import BeautifulSoup as soup
from xlwt import Workbook


urlBeginning = "https://www.mygrocerydeals.com/deals?utf8=%E2%9C%93&authenticity_token=KFo1qPeErMj0RspD%2F8AhWJlc9BChi8x8L6irKF9pfCDTL4%2B7TkK0EgkeC85l933qffsBAuiYEHhOFgqQUy0nJg%3D%3D&remove%5B%5D=chains&remove%5B%5D=categories&remove%5B%5D=collection&remove%5B%5D=collection_id&q="
urlEnd = "&supplied_location=93107&latitude=34.42&longitude=-119.69999999999999"
product = input("Please enter the product: ")
fileName = product.title().replace(" ", "") + ".xls"
product = product.replace(" ", "+")

url = urlBeginning + product + urlEnd 	#page URL


uclient = ureq(url) 					#opening connection to website	
pageHTMl = uclient.read()				#reading HTML
uclient.close()
content = soup(pageHTMl, "html.parser")

#grabs each product
itemContainers = content.findAll("div", {"data-type":"special"})

wb = Workbook()
sheet1 = wb.add_sheet("Sheet 1")
sheet1.write(0,0,"Product Name")
sheet1.col(0).width = 14000
sheet1.write(0,1, "Size/Count")
sheet1.col(1).width = 2500
sheet1.write(0,2,"Price")
sheet1.col(2).width = 3000
sheet1.write(0,3,"Deal End")
sheet1.col(3).width = 4000
sheet1.write(0,4,"Store")
sheet1.col(4).width = 4000

count = 1
for container in itemContainers:
	productNameContainer = container.findAll("p", {"class":"deal-productname"})
	productName = productNameContainer[0].text
	sheet1.write(count, 0, productName)

	sizeContainer = container.findAll("div", {"class":"uom"})
	size = sizeContainer[0].text
	sheet1.write(count, 1, size)

	priceContainer = container.findAll("span", {"class":"pricetag"})
	price = priceContainer[0].text
	sheet1.write(count, 2, price)

	dealEndContainer = container.findAll("div", {"class":"expirydate"})
	dealEnd = dealEndContainer[0].text
	sheet1.write(count, 3, dealEnd)

	storeNameContainer = container.findAll("p", {"class":"deal-storename"})
	storeName = storeNameContainer[0].text
	sheet1.write(count, 4, storeName)

	count+=1



wb.save(fileName)
