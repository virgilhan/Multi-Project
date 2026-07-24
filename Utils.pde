static class Utils {
  
  //Most of these are unused, I copied the classes over from an earlier project with some edits
  
  public static float dot (float[]A, float[]B){
    if(A.length != B.length){
      throw new ArithmeticException("Incompatible lengths dot");
    }
    float product = 0;
    for (int i = 0; i < A.length; i++){
      product += A[i] * B[i];
    }
    return product;
  }
  
  public static float[][] multiply(float[][]A, float[][]B){
    if(A[0].length != B.length){
      throw new ArithmeticException("Incompatible lengths matrix");
    }
    float[][] product = new float[A.length][B.length];
    for (int i = 0; i < A.length; i++){
       for (int j = 0; j < A[0].length; j++){
          for (int k = 0; k < B[0].length; k++){
            product[i][j] += A[i][k] * B[k][j];
        }
      }
    }
   return product;
  }
  
public static float[] multiplyPoint(float[] A, float[][] B){
    float[] product = new float[B[0].length];
    if (A.length==3 && B.length ==4){
      float[] A_transform = new float[4];
      for (int i = 0; i < A.length; i++) A_transform[i] = A[i];
      A_transform[3] = 1;
      A = A_transform;
    }
    if (A.length!=B.length){
        throw new ArithmeticException("Incompatible lengths");
    }
    for (int j = 0; j < B.length; j++){
        for (int k = 0; k < B[0].length; k++){
            product[j] += A[k] * B[k][j];
        }
    }
    
    float w = A[0]*B[0][3] + A[1]*B[1][3] + A[2]*B[2][3] + B[3][3];

    if (w != 1 && w != 0) {
        product[0] /= w;
        product[1] /= w;
        product[2] /= w;
    }
    return new float[]{product[0], product[1], product[2]};
  }

//don't translate vectors, so ignore last row/column of B
public static float[] multiplyDirection(float[] A, float[][] B){
  float[] product = new float[3];
    for (int j = 0; j < 3; j++){
        for (int k = 0; k < 3; k++){
            product[j] += A[k] * B[k][j];
        }
    }
  return product;
}
 
public static float[] multiplyConst(float[]A, float B){
  for (int i = 0; i < A.length; i++){
    A[i] = A[i]*B;
  }
  return A;
}

public static float[] normalize(float[]A){
  float sum = 0;
  for (float f : A) sum += f*f;
  if (sum > 0) return multiplyConst(A, 1/sqrt(sum));
  return A;
}

public static float magnitude(float[]A){
  float sum = 0;
  for (float f : A) sum += f*f;
  return sqrt(sum);
}

public static float[][] transpose(float[][]A){
  float[][] trans = A;
    for (int i = 0; i < A.length; i++){
      for (int j = 0; j < A[0].length; j++){
        trans[j][i] = A[i][j];
      }
    }
  return trans;
}

public static float[] add(float[] A, float[] B){
  if (A.length!=B.length){
        throw new ArithmeticException("Incompatible lengths addition");
    }
  float[] sum = new float[A.length];
  
  for (int i = 0; i < A.length; i++){
     sum[i] = A[i] + B[i];
  }
  return sum;
}

public static float[] subtract(float[] A, float[] B){
  if (A.length!=B.length){
        throw new ArithmeticException("Incompatible lengths subtraction");
    }
  float[] diff = new float[A.length];
  
  for (int i = 0; i < A.length; i++){
     diff[i] = A[i] - B[i];
  }
  return diff;
}

public static float[] cross(float[] A, float[] B){ //for 3d only
  float[] prod = new float[3];
  
  prod[0] = A[1] * B[2] - A[2] * B[1];
  prod[1] = A[2] * B[0] - A[0] * B[2];
  prod[2] = A[0] * B[1] - A[1] * B[0];
  
  return prod;
}

public static float[][] invert(float a[][])
// source: swissmakers gmbh https://code.swissmakers.ch/swissmakers_gmbh/programming-examples/src/commit/f4fa9cdf8e0b8bb83068cb251c0ae7ef629b065f/java/Numerical_Problems/Java%20Program%20to%20Find%20Inverse%20of%20a%20Matrix.java
    {
        int n = a.length;
        float x[][] = new float[n][n];
        float b[][] = new float[n][n];
        int index[] = new int[n];
        for (int i=0; i<n; ++i)
            b[i][i] = 1;
// Transform the matrix into an upper triangle
        gaussian(a, index);
// Update the matrix b[i][j] with the ratios stored
        for (int i=0; i<n-1; ++i)
            for (int j=i+1; j<n; ++j)
                for (int k=0; k<n; ++k)
                    b[index[j]][k]
                    -= a[index[j]][i]*b[index[i]][k];
// Perform backward substitutions
        for (int i=0; i<n; ++i)
            {
                x[n-1][i] = b[index[n-1]][i]/a[index[n-1]][n-1];
                for (int j=n-2; j>=0; --j)
                    {
                        x[j][i] = b[index[j]][i];
                        for (int k=j+1; k<n; ++k)
                            {
                                x[j][i] -= a[index[j]][k]*x[k][i];
                            }
                        x[j][i] /= a[index[j]][j];
                    }
            }
        return x;
    }
    
// Method to carry out the partial-pivoting Gaussian
// elimination.  Here index[] stores pivoting order.

public static void gaussian(float a[][], int index[])
    {
        int n = index.length;
        float c[] = new float[n];
// Initialize the index
        for (int i=0; i<n; ++i)
            index[i] = i;
// Find the rescaling factors, one from each row
        for (int i=0; i<n; ++i)
            {
                float c1 = 0;
                for (int j=0; j<n; ++j)
                    {
                        float c0 = Math.abs(a[i][j]);
                        if (c0 > c1) c1 = c0;
                    }
                c[i] = c1;
            }
// Search the pivoting element from each column
        int k = 0;
        for (int j=0; j<n-1; ++j)
            {
                float pi1 = 0;
                for (int i=j; i<n; ++i)
                    {
                        float pi0 = Math.abs(a[index[i]][j]);
                        pi0 /= c[index[i]];
                        if (pi0 > pi1)
                            {
                                pi1 = pi0;
                                k = i;
                            }
                    }
                // Interchange rows according to the pivoting order
                int itmp = index[j];
                index[j] = index[k];
                index[k] = itmp;
                for (int i=j+1; i<n; ++i)
                    {
                        float pj = a[index[i]][j]/a[index[j]][j];
// Record pivoting ratios below the diagonal
                        a[index[i]][j] = pj;
// Modify other elements accordingly
                        for (int l=j+1; l<n; ++l)
                            a[index[i]][l] -= pj*a[index[j]][l];
                    }
       }
    }
  
public static float[][] arrayToMatrix(float[] nums, int arrayWidth){
  int arrayHeight = nums.length / arrayWidth;
  
  float[][] nums2d = new float[arrayHeight][arrayWidth];
  for (int i = 0; i < nums.length; i++){
    nums2d[i / arrayWidth][i % arrayWidth] = nums[i];
  }
  return nums2d;
}
}
