#include <math.h>
#include <stdio.h>
double mysin(double num){
    return sin(num);
}
double mycos(double num){
    //printf("%f\n",num);
    return sin(num+M_PI/2);
}
