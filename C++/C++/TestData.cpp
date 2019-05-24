//
//  TestData.cpp
//  C++
//
//  Created by Sai Kathika on 5/18/19.
//  Copyright © 2019 Sai Kathika. All rights reserved.
//

#include "TestData.hpp"
#include <string>
using namespace std;
//struct Data{
double products_scanned = 0.0;
double products_added = 0.0;
double products_searched = 0.0;
const char* product_name[100];
int count_product = 0;
    void getData(int products_scanned1, int products_added2 , int products_searched3){
        
        products_scanned = products_scanned1;
        products_added =products_added2;
        products_searched=products_searched3;
        
    }
    void set_scanned(double s){
        products_scanned = s;
    }
    void update_count(){
        count_product++;
    }
    void update_products_searched(){
        // call in swift and print updated stats
        products_searched++;
    }
    void update_products_scanned(){
        // call in swift and print updated stats
        products_scanned++;
    }
    void update_products_added(){
        // call in swift and print updated stats
        products_added++;
    }
    // return the count back to print in swift
    double return_products_searched(){
        
        return products_searched;
    }
   double return_products_scanned(){
        return products_scanned;
    }
    double return_products_added(){
        return products_added;
    }
    void add_products(const char *s){
        product_name[count_product] = s;
        count_product++;
    }
    const char *getPersonName(void){
        char name[200];
        snprintf(name, sizeof name, "%s %s", "Hello", "Swift!");
        return strdup(name);
    }
//    void print_elements(){
//        for (auto i= 0; i<3;i++){
//            cout << product_name[i];
//        }
//   }
//   char* return_vector(){
//        return product_name;
//    }

    
//};
float Data(){
    // store products scanned during session
    // items inputed to firebase database
    // store producst searched during session
    return 5.0;
}

//void getData(int products_scanned, int products_added , int products_searched){
//    struct Data a;
//    a.products_scanned = products_scanned;
//    a.products_added =products_added;
//    a.products_searched=products_searched;
//   
//}
//void update_products_searched(){
//    // call in swift and print updated stats
//    struct Data a;
//    a.products_searched++;
//}
//void update_products_scanned(){
//    // call in swift and print updated stats
//    struct Data a;
//    a.products_scanned++;
//}
//void update_products_added(){
//    // call in swift and print updated stats
//    struct Data a;
//    a.products_added++;
//}
//// return the count back to print in swift
//int return_products_searched(){
//    struct Data a;
//    return a.products_searched;
//}
//int return_products_scanned(){
//    struct Data a;
//    return a.products_scanned;
//}
