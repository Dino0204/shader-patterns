varying vec2 vUv;

uniform float uTime;
uniform vec2 uResolution;
uniform float uGridSize;
uniform float uDensityPower;
uniform float uJitter;
uniform vec3 uDotColor;
uniform vec3 uBgColor;

float hash(vec2 p){
        return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main()
{
    // 종횡비 보정: 점이 동그랗고 격자가 정사각형이 되도록
    vec2 uv = vUv;
    uv.x *= uResolution.x / uResolution.y;

    // 균일한 격자 위치
    vec2 grid = uv * uGridSize;
    vec2 id   = floor(grid);          // 칸 주소
    vec2 cell = fract(grid) - 0.5;    // 칸 안 좌표 (-0.5~0.5, 중심 0)

    // 좌→우 밀도 곡선 (x^power). 방향 기준은 보정 전 vUv.x
    float density = pow(vUv.x, uDensityPower);

    // 칸마다 고정된 난수로 크기를 흩뜨려 경계를 우둘투둘하게
    float rnd    = hash(id);
    float radius = clamp(density + (rnd - 0.5) * uJitter, 0.0, 1.0) * 0.5;

    // 점 그리기 (radius 안쪽 = 점)
    float dot   = smoothstep(radius, radius - 0.05, length(cell));
    vec3  color = mix(uBgColor, uDotColor, dot);

    gl_FragColor = vec4(color, 1.0);
}
