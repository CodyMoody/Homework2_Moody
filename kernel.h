#ifndef KERNEL_H
#define KERNEL_H

// Wrappers
void compAddArray(float *out, float *in, float *array2, int len);

void setValArray(float *out, float val, int len);

void linearArray(float *out, float *in_1, float *in_2, float scalar, int len);

void compMultArray(float *out, float *in_1, float *in_2, int len);

void sumParts(float *out, float *in, int len);

#endif
