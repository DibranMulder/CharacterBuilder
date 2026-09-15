shader_type canvas_item;
uniform vec2 revealed[15];
uniform int count = 0;
float grain(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(grain(i),grain(i+vec2(1,0)),f.x),mix(grain(i+vec2(0,1)),grain(i+vec2(1,1)),f.x),f.y);
}
void fragment() {
 vec2 p=UV*vec2(2800,1800)-vec2(900,700);
 float n=noise(p*.012)+noise(p*.029)*.35;
 float cover=1.0;
 for(int i=0;i<15;i++) {
  if(i>=count) break;
  cover=min(cover,smoothstep(68.0,118.0,distance(p,revealed[i])+n*17.0));
 }
 vec3 fog=mix(vec3(.20,.23,.22),vec3(.38,.40,.35),n*.65);
 COLOR=vec4(fog,cover);
}
