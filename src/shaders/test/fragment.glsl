varying vec2 vUv;

uniform float uTime;
uniform float uGridSize;


vec2 random(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));

    return fract(sin(p) * 43758.5453);
}

void main()
{
    // ── 기초 세팅 ──
    // 일단 UV 공간을 그대로 색으로 출력한다.
    // (좌하단 = 검정, 오른쪽으로 갈수록 빨강, 위로 갈수록 초록)
    // 이 좌표 uv 위에서 floor()/fract() 로 그리드를 나누기 시작하면 된다.
    vec2 uv = vUv - 0.5;   // 원점을 화면 중앙으로 (-0.5 ~ 0.5)
    uv *= uGridSize;       // GUI 슬라이더로 칸 개수 조절

    vec2 cellId = floor(uv);
    vec2 cellPointPosition = fract(uv);
    float m_dist = 10.0;
    vec2  m_cellId = vec2(0.0);   // 이긴 점(가장 가까운 점)의 칸 ID

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));
            vec2 randomPoint = random(cellId + neighbor);

            vec2 diff = (neighbor + randomPoint) - cellPointPosition;
            float dist = length(diff);

            if (dist < m_dist) {                 // min() 대신 if 로: 누가 이겼는지 잡으려고
                m_dist = dist;
                m_cellId = cellId + neighbor;    // 이긴 칸 ID도 같이 기록
            }
        }
    }

    // 파편마다 다른 단색으로 칠하기 (셀 ID -> 무작위 색)
    vec3 cellColor = vec3(random(m_cellId), random(m_cellId).y);

    gl_FragColor = vec4(cellColor, 1.0);

    
}
