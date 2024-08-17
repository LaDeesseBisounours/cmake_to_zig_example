#include <stdio.h>

int add(int a, int b);

int main() {
    int a = 4;
    int b = 7;
    printf("adding %d + %d = %d\n", a, b, add(a, b));
    return 0;
}
