#include "kernel.h"
#include <stdio.h>
#define TPB 32

// Set of functions to be performed on the device
__device__ float setValue(float val)
{
  return val;
}

__device__ float add(float num1, float num2)
{
  return num1 + num2;
}

__device__ float mult(float num1, float num2)
{
  return num1 * num2;
}


// Set of kernel functions
__global__ void setValKernel(float *d_out, float value)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  d_out[i] = setValue(value);
}

__global__ void scalarMultKernel(float *d_out, float scalar, float *d_in)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  d_out[i] = mult(scalar, d_in[i]);
}

__global__ void componentAddKernel(float *d_out, float *d_in, float *array2)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  d_out[i] = add(d_in[i],array2[i]);
}

__global__ void linearFunctionKernel(float *d_out, float scalar, float *d_in, float *array2)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  d_out[i] = add(mult(scalar, d_in[i]), array2[i]);
}

__global__ void componentMultKernel(float *d_out, float *d_in, float *array2)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  d_out[i] = mult(d_in[i],array2[i]);
}

__global__ void sumPartsKernel(float *accum, float *d_in)
{
  const int i = blockIdx.x*blockDim.x + threadIdx.x;
  *accum += d_in[i];
}


// Creates arrays that hold answers and copy to host
//WORKS AS INTENDED
void setValArray(float *out, float val, int len)
{
  // Pointers to device arrays
  float *d_out = 0;

  // Allocate memory for device array
  cudaMalloc(&d_out, len*sizeof(float));

  // Launch kernel to compute and store
  setValKernel<<<len/TPB, TPB>>>(d_out, val);
  
  // Copy from device to host
  cudaMemcpy(out, d_out, len*sizeof(float), cudaMemcpyDeviceToHost);

  // Free the memory
  cudaFree(d_out);
}


//WORKS AS INTENDED
void compAddArray(float *out, float *in, float *array2, int len)
{
  // Pointers to device arrays
  float *d_in = 0;
  float *d_out = 0;
  float *d_array2 = 0;

  // Allocate memory for device arrays
  cudaMalloc(&d_in, len*sizeof(float));
  cudaMalloc(&d_out, len*sizeof(float));
  cudaMalloc(&d_array2, len*sizeof(float));

  // Copy from host to device
  cudaMemcpy(d_in, in, len*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_array2, array2, len*sizeof(float), cudaMemcpyHostToDevice);

  // Launch kernel to compute and store
  componentAddKernel<<<len/TPB, TPB>>>(d_out, d_in, d_array2);
  
  // Copy from device to host
  cudaMemcpy(out, d_out, len*sizeof(float), cudaMemcpyDeviceToHost);

  // Free the memory
  cudaFree(d_in);
  cudaFree(d_out);
  cudaFree(d_array2);
}

//WORKS AS INTENDED
void linearArray(float *out, float *in_1, float *in_2, float scalar, int len)
{
  // Pointers to device arrays
  float *d_in_1 = 0;
  float *d_in_2 = 0;
  float *d_out = 0;

  // Allocate memory for device arrays
  cudaMalloc(&d_in_1, len*sizeof(float));
  cudaMalloc(&d_in_2, len*sizeof(float));
  cudaMalloc(&d_out, len*sizeof(float));

  // Copy from host to device
  cudaMemcpy(d_in_1, in_1, len*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_in_2, in_2, len*sizeof(float), cudaMemcpyHostToDevice);

  // Launch kernel to compute and store
  linearFunctionKernel<<<len/TPB, TPB>>>(d_out, scalar, d_in_1, d_in_2);
  
  // Copy from device to host
  cudaMemcpy(out, d_out, len*sizeof(float), cudaMemcpyDeviceToHost);

  // Free the memory
  cudaFree(d_in_1);
  cudaFree(d_in_2);
  cudaFree(d_out);
}

//WORKS AS INTENDED
void compMultArray(float *out, float *in_1, float *in_2, int len)
{
  // Pointers to device arrays
  float *d_in_1 = 0;
  float *d_in_2 = 0;
  float *d_out = 0;

  // Allocate memory for device arrays
  cudaMalloc(&d_in_1, len*sizeof(float));
  cudaMalloc(&d_in_2, len*sizeof(float));
  cudaMalloc(&d_out, len*sizeof(float));

  // Copy from host to device
  cudaMemcpy(d_in_1, in_1, len*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_in_2, in_2, len*sizeof(float), cudaMemcpyHostToDevice);

  // Launch kernel to compute and store
  componentMultKernel<<<len/TPB, TPB>>>(d_out, d_in_1, d_in_2);
  
  // Copy from device to host
  cudaMemcpy(out, d_out, len*sizeof(float), cudaMemcpyDeviceToHost);

  // Free the memory
  cudaFree(d_in_1);
  cudaFree(d_in_2);
  cudaFree(d_out);
}

//MOST LIKELY WORKS AS INTENDED AND HARD TO DEBUG
void sumParts(float *out, float *in, int len)
{
  // Pointer to device array
  float *d_in = 0;

  // Accumulating variable
  float *d_accum = 0;

  // Allocate memory for device arrays
  cudaMalloc(&d_in, len*sizeof(float));
  cudaMalloc(&d_accum, sizeof(float));

  // Copy from host to device
  cudaMemcpy(d_in, in, len*sizeof(float), cudaMemcpyHostToDevice);
  
  // Create d_accum
  cudaMemset(d_accum, 0, sizeof(int));

  // Launch kernel to compute and store
  sumPartsKernel<<<len/TPB, TPB>>>(d_accum, d_in);
  
  // Copy from device to host
  cudaMemcpy(out, d_accum, sizeof(float), cudaMemcpyDeviceToHost);

  // Free the memory
  cudaFree(d_in);
  cudaFree(d_accum);
}
