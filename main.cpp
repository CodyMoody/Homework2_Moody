#include "kernel.h"
#include <stdlib.h>
#include <stdio.h>
#define N 100000

//Main Function

int main(int argc, char *argv[])
{
  //Set values in u2 and v2
  float *in = (float*)calloc(N, sizeof(float));
  float *u2 = (float*)calloc(N, sizeof(float));
  float *v2 = (float*)calloc(N, sizeof(float));
  
  setValArray(u2, 0.25, N);
  setValArray(v2, 0.75, N);
  
  // Calculating u2 + v2
  float *u2plusv2 = (float*)calloc(N, sizeof(float));
  compAddArray(u2plusv2, u2, v2, N);

  // Calculating -3 * u2 + v2
  float *lineartest = (float*)calloc(N, sizeof(float));
  linearArray(lineartest, u2, v2, -3.0, N);
  
  // Calculating u2 * v2
  float *u2multv2 = (float*)calloc(N, sizeof(float));
  compMultArray(u2multv2, u2, v2, N);
  
  // Calculating w2
  float *w2 = (float*)calloc(N, sizeof(float));
  compAddArray(w2, u2, v2, N);
  // Calculating w2 * w2 component wise multiplication
  float *w2multw2 = (float*)calloc(N, sizeof(float));
  compMultArray(w2multw2, w2, w2, N);
  // Calculate the sum of all parts of w2 * w2
  float w2dotw2 = 0;
  sumParts(&w2dotw2, w2multw2, N);

  // Free memory
  free(in);
  free(u2);
  free(v2);
  free(u2plusv2);
  free(lineartest);
  free(u2multv2);
  free(w2);
  free(w2multw2);
  return 0;
}
