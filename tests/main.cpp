import a_module;
#include <iostream>
int main() {

    // C++ Version check we default to C++23 but minimum support is C++20
    if (__cplusplus == 202302L) {
        std::cout << "Success! You are running pure C++23.\n";
    } else if (__cplusplus > 202302L) {
        std::cout << "Even better! You are running an experimental newer standard (C++26).\n";
    } else {
        std::cout << "Oops! Current value is: " << __cplusplus << "\n";
        std::cout << "Expected: 202302 (C++23) or higher.\n";
    }
    
    a_module::hey();    
    return 0;
}

