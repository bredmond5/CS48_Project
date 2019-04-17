package webscrape;

// import org.apache.poi.hssf.usermodel.HSSFCell;
// import org.apache.poi.hssf.usermodel.HSSFRow;
// import org.apache.poi.hssf.usermodel.HSSFSheet;
// import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.util.Scanner;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class priceScrape{
	public static void main(String[] args){
		final String walmart = "https://www.walmart.com/ip/Frito-Lay-Fun-Times-Mix-Variety-Pack-40-Count/440311832";
		final String base = "https://www.mygrocerydeals.com/deals?utf8=%E2%9C%93&authenticity_token=KFo1qPeErMj0RspD%2F8AhWJlc9BChi8x8L6irKF9pfCDTL4%2B7TkK0EgkeC85l933qffsBAuiYEHhOFgqQUy0nJg%3D%3D&remove%5B%5D=chains&remove%5B%5D=categories&remove%5B%5D=collection&remove%5B%5D=collection_id&q=";
		final String ending = "&supplied_location=93107&latitude=34.42&longitude=-119.69999999999999";
		// final String ending = "&supplied_location=";
		
		Scanner input1 = new Scanner(System.in);
		String product = input1.nextLine();
		product = product.replaceAll(" ", "+");

		// Scanner input2 = new Scanner(System.in);
		// String zipCode = input2.nextLine();

		// HSSFWorkbook workbook = new HSSFWorkbook();
		// HSSFSheet sheet = workbook.createSheet("Sales");
		
		try{
			final Document document = Jsoup.connect(base+product+ending).get();
			int count = 0;
			for (Element item : document.select("div.container-tile.deal.paged.special-tile")){
				String price = item.select("span.pricetag").text();
				String productName = item.select("p.deal-productname").text();
				String storeName = item.select("p.deal-storename").text();
				String dealEnd = item.select("div.expirydate").text();

				// HSSFRow row = sheet.createRow(count);
				// HSSFCell cell1 = row.createCell(0);
    //             HSSFCell cell2 = row.createCell(1);
    //             HSSFCell cell3 = row.createCell(2);
    //             HSSFCell cell4 = row.createCell(3);
                
    //             cell1.setCellValue(productName);
    //             cell2.setCellValue(price);
    //             cell3.setCellValue(dealEnd);
    //             cell4.setCellValue(storeName);
    //             cout++;

				System.out.println("Product Name: " + productName);
				System.out.println("Price: " + price);
				System.out.println(dealEnd);
				System.out.println("Store: " + storeName + "\n");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		// workbook.write(new FileOutputStream("deals.xls")); //title what you want the excel file to be called
        // workbook.close();

		/*try{
			final Document document = Jsoup.connect(walmart).get();
			final String newPrice = document.select("span.hide-content-m").text();
			final String originalPrice = document.select("div.display-inline-block.product-secondary-price.Price-enhanced").text();
			System.out.println("Original Price: "+ originalPrice);
			System.out.println("New Price: "+ newPrice);
		} catch (Exception e) {
			e.printStackTrace();
		}*/

	}
}