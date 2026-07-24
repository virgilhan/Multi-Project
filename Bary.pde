class Bary {
  float t, u, v;
  int i;
  
  Bary(){
    this.t = 0;
    this.u = 0;
    this.v = 0;
    this.i = 0;
  }
  
  Bary(float t, float u, float v){
    this.t = t;
    this.u = u;
    this.v = v;
    this.i = 0;
  }
  
  Bary(float t, float u, float v, int i){
    this.t = t;
    this.u = u;
    this.v = v;
    this.i = i;
  }
  
  public void setI(int i){this.i = i;}
}
