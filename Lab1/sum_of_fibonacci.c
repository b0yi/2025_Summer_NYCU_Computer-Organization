#include <stdio.h>

int fibonacci(int n) {
    // TODO (Please use recursion to calculate Fibonacci(n))
    if(n <= 1) {
        return n;
    }
    return fibonacci(n-1) + fibonacci(n-2);
}

int fibonacciSum(int n) {
    int sum = 0;
    for (int i = 0; i <= n; ++i) {
        sum += fibonacci(i);
    }
    return sum;
}

int main() {
    int num;
    printf("Please input a number: ");
    scanf("%d", &num);

    printf("The sum of Fibonacci(0) to Fibonacci(%d) is: %d\n", num, fibonacciSum(num));

    return 0;
}
