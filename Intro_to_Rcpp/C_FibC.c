/* A C function to compute Fibonacci numbers  */

void C_FibC(int *n, int *out)
{
  int nC = n[0];
  out[0] = 1;
  out[1] = 1;
  int i;
  for(i=2; i<nC; i++)
    {
      out[i] = out[i-1] + out[i-2];
    }
}

