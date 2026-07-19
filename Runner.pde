import java.util.stream.*;

void loadFile(String filepath) {
  String[] lines = loadStrings(filepath);
  numTris = Integer.parseInt(lines[0]);
  facesIndex = int(lines[1].split(" "));
  tris = int(lines[2].split(" "));
  
  float[] v = float(lines[3].split(" "));
  verts = Utils.arrayToMatrix(v, 3);
}

static float kEpsilon = 1e-8;
int[] frameBuffer;

void render(float fov, float[][] cameraToWorld) {
  frameBuffer = new int[width*height];

  int[] pix = frameBuffer;

  float scale = tan(radians(fov));
  float imageAspectRatio = width / (float)height;

  float[] orig;
  float[] o = {0, 0, 0};
  orig = Utils.multiplyPoint(o, cameraToWorld);

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      float x = (2 * (i + 0.5) / (float)width - 1) * imageAspectRatio * scale;
      float y = (1 - 2 * (j + 0.5) / (float)height) * scale;

      float[] v = {x, y, -1};

      float[] dir;
      dir = Utils.multiplyDirection(v, cameraToWorld);
      dir = Utils.normalize(dir);

      pix[j * width + i] = castRay(orig, dir);
    }
  }
}

//so, the reason why this function is so nothing burger is bc the tutorial wrote it
//to be able to check multiple meshes for intersections, but i am way too lazy to do that
float[] trace(float[] origin, float[] dir) {
  float[] tuvi = intersect(origin, dir);
  if (tuvi != null) {
    return tuvi;
  }
  return null;
}

int castRay(float[] origin, float[] dir) {
  int hitColor = 255;
  float[] tuvi = trace(origin, dir);
  if (tuvi != null) {
    int i = (int) tuvi[3]; //yes yes i know
    float[] v0 = verts[tris[i*3]];
    float[] v1 = verts[tris[i*3+1]];
    float[] v2 = verts[tris[i*3+2]];

    float[] hitNormal = Utils.cross(Utils.subtract(v1, v0), Utils.subtract(v2, v0));
    hitNormal = Utils.normalize(hitNormal);

    //normalize ndotview to [0,1] as it is a dot prod
    float NdotView = max(0, Utils.dot(hitNormal, Utils.multiplyConst(dir, -1)));

    hitColor = (int) (NdotView * 255);
  }
  print(hitColor);
  return hitColor;
}

//returns parameter t and barycentric coordinates u, v
float[] rayTriangleIntersect(float[] origin, float[] dir, float[] v0, float[] v1,
  float[]v2) {
  float[] v0v1 = Utils.subtract(v1, v0);
  float[] v0v2 = Utils.subtract(v2, v0);

  float[] N = Utils.cross(v0v1, v0v2);
  float denom = Utils.dot(N, N);

  float NdotRayDir = Utils.dot(N, dir);

  if (abs(NdotRayDir) < kEpsilon) return null; //parallel case

  float d = -Utils.dot(N, v0);
  float t = -(Utils.dot(N, origin) + d) / NdotRayDir;

  if (t < 0) return null;

  float[] P = Utils.add(origin, Utils.multiplyConst(dir, t));

  float[] C;

  //check if ray intersection w plane is inside triangle by checking if it is on the left/right of each side

  float[] v1p = Utils.subtract(P, v1);
  float[] v1v2 = Utils.subtract(v2, v1);
  C = Utils.cross(v1v2, v1p);
  float u = Utils.dot(N, C);
  if (u < 0) return null;

  float[] v2p = Utils.subtract(P, v2);
  float[] v2v0 = Utils.subtract(v0, v2);
  C = Utils.cross(v2v0, v2p);
  float v = Utils.dot(N, C);
  if (v < 0) return null;

  float[] v0p = Utils.subtract(P, v0);
  C = Utils.cross(v0v1, v0p);
  if (Utils.dot(N, C) < 0) return null;

  //barycentric coords
  u /= denom;
  v /= denom;

  float[] bary = {t, u, v};

  return bary;
}

//returns parameter t; coords u, v; triangle index i (this is a terrible implementation but what are you gonna do)
float[] intersect(float[] origin, float[] dir) {
  float[] tuvi = new float[4];
  float t = Float.MAX_VALUE;

  boolean intersect = false;
  for (int i = 0; i < numTris; i++) {
    float[] v0 = verts[tris[i*3]];
    float[] v1 = verts[tris[i*3+1]];
    float[] v2 = verts[tris[i*3+2]];

    float[] bary = rayTriangleIntersect(origin, dir, v0, v1, v2);

    if (bary != null && bary[0] < t) {
      tuvi[0] = bary[0];
      tuvi[1] = bary[1];
      tuvi[2] = bary[2];
      tuvi[3] = i;

      t = bary[0];
      intersect = true;
    }
  }
  if (intersect == false) return null;
  return tuvi;
}

float focalLength = 35; // 35mm Full Aperture
float filmApertureWidth = 0.825;
float filmApertureHeight = 0.446;
static float inchToMm = 25.4;
float nearClippingPlane = 0.1;
float farClippingPlane = 1000;

int numTris;
int[] facesIndex;
int[] tris;
float[][] verts;
  

enum FitResolutionGate {
  kFill, kOverscan
};
FitResolutionGate fitFilm = FitResolutionGate.kOverscan;

void setup() {
  size(640, 480);
  pixelDensity(1);
  
  loadFile("cow.txt");

  float top = ((filmApertureHeight * inchToMm / 2) / focalLength) * nearClippingPlane;
  float right = ((filmApertureWidth * inchToMm / 2) / focalLength) * nearClippingPlane;  //screen window edge coordinates

  float xscale = 1;
  float yscale = 1;

  right *= xscale;
  top *= yscale;
  float left = -right;
  float bottom = -top;

  println("Screen window coordinates: " + bottom + " " + left + " " + top + " " + right);

  //float[][] cameraToWorld = {{-0.95424, 0, 0.299041, 0, },
  //  {0.0861242, 0.95763, 0.274823, 0},
  //  {-0.28637, 0.288002, -0.913809, 0},
  //  {-3.734612, 7.610426, -14.152769, 1}};
  float[][] worldToCamera = {{0.707107, -0.331295, 0.624695, 0},
                             {0, 0.883452, 0.468521, 0},
                             {-0.707107, -0.331295, 0.624695, 0},
                             {-1.63871, -5.747777, -40.400412, 1}};
  float[][] cameraToWorld = Utils.invert(worldToCamera);

  float fov = degrees(2 * atan((filmApertureHeight * inchToMm / 2) / focalLength));
  render(fov, cameraToWorld);

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      int c = frameBuffer[j * width + i];
      set(i, j, color(c));
    }
  }
}
