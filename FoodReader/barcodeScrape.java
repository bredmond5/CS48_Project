package webscrape;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.FileOutputStream;
import java.io.IOException;

public class barcodeScrape {
    public static void main(String[] args)throws IOException {
        final String url=
                "https://www.imdb.com/chart/top";
        double rateArray[] = new double[250];
        String titleArray[] = new String[250];
        try{
            final Document document = Jsoup.connect(url).get();
            int count = 0;
            for(Element row: document.select("tbody.lister-list tr")) {
                //May need to check if table has a blank line
                final String title = row.select("td.titleColumn").text();
                Elements x = row.select("td.ratingColumn.imdbRating");
                final String Temprating = x.text();
                final double rating = Double.parseDouble(Temprating);
                titleArray[count] = title;
                rateArray[count] = rating;
                count++;
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("Sheet 1");
        for(int x = 0; x<250;x++) {
            HSSFRow row = sheet.createRow(x);
            HSSFCell cell1 = row.createCell(0);
            HSSFCell cell2 = row.createCell(1);
            cell1.setCellValue(titleArray[x]);
            cell2.setCellValue(rateArray[x]);
        }
        workbook.write(new FileOutputStream("excel.xls"));
        workbook.close();
    }
}
