//
//  TestData.hpp
//  C++
//
//  Created by Sai Kathika on 5/18/19.
//  Copyright © 2019 Sai Kathika. All rights reserved.
//

//#ifndef TestData_hpp
#define TestData_hpp

#include <stdio.h>

//#include <vector>
#ifdef __cplusplus
extern "C" {
#endif
     float Data();
    void getData(int products_scanned, int items_inputed, int products_searched);
    void update_products_searched();
    void update_products_scanned();
    void update_products_added();
   double return_products_scanned();
    double return_products_searched();
    double return_products_added();
    void add_products(char* s);
    void print_elements();
    //std::vector<std::string> return_vector();
#ifdef __cplusplus
}
#endif /* TestData_hpp */
