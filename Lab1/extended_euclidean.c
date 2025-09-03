#include <stdio.h>

int mod_inverse(int a, int b) {
	// TODO
    int old_r = a, r = b;
    int old_x = 1, x_curr = 0;
    int old_y = 0, y_curr = 1;

    while(r != 0) {
        int q = old_r / r;

        int tempr = old_r - q*r;
        old_r = r;
        r = tempr;

        int tempx = old_x - q*x_curr;
        old_x = x_curr;
        x_curr = tempx;

        int tempy = old_y - q*y_curr;
        old_y = y_curr;
        y_curr = tempy;
    }
    if (old_r == 1) {
        int result =  old_x % b;
        if (result < 0) result += b;
        return result;
    }
    else return -1;
    
}

int main() {
    int a, b;
    printf("Enter the number: ");
    scanf("%d", &a);
    printf("Enter the modulo: ");
    scanf("%d", &b);

    int inv = mod_inverse(a, b);
    if (inv == -1) {
        printf("Inverse not exist.\n");
    } else {
        printf("Result: %d\n", inv);
    }

    return 0;
}
