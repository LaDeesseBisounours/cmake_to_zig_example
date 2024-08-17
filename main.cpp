#include <iostream>

extern "C" { int add(int a, int b); }


int main() {
    int a = 4;
    int b = 7;
    std::cout << "adding " <<  a << " + "  << b << " = "  << add(a, b) << std::endl;
    return 0;
}

