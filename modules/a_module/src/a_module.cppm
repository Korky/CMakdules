// Legacy C++20
module;
#include <iostream>

// experimental in C++23
// import std; 

// actual module declaration
export module a_module;

// Internal Helper function not exposed in API
void print(const char * buff) {
    std::cout << buff;
}

// optional but using namesapce to diffirintiate
// from what module the type/function is comming from.
export namespace a_module {
    // Also helps functions inside
    // get exported with namespace.
    void hey(){
        print("Hey from Module A \n");        
    }
}
