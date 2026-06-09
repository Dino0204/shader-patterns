varying vec2 vUv;

uniform float uTime;
uniform float uGridSize;
uniform float uRefractAmount;
uniform sampler2D uTexture;
uniform float uCrackWidth;
uniform float uCrackBrightness;
uniform float uAberration;
uniform vec3 uCrackColor;


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
    vec2  m_diff = vec2(0.0);     // 이긴 점까지의 상대 벡터 (경계 계산에 필요)

    // 1차 패스: 가장 가까운 점 찾기
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
                m_diff = diff;                   // 이긴 점까지의 벡터도 저장
            }
        }
    }

    // 2차 패스: 가장 가까운 경계(균열)까지의 거리
    float m_edge = 10.0;
    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x),float(y));
            vec2 randomPoint = random(cellId + neighbor);
            vec2 diff = (neighbor + randomPoint) - cellPointPosition;

            // 이긴 점 자기 자신은 건너뛰기 (거의 같은 벡터면 skip)
            if (dot(m_diff - diff, m_diff - diff) > 0.0001) {
                // 내 점과 이웃 점의 수직이등분선(=셀 경계)까지 거리
                m_edge = min(m_edge,
                             dot(0.5 * (m_diff + diff), normalize(diff - m_diff)));
            }
        }
    }

    // ── 4층: 굴절 ──
    // 파편(m_cellId)마다 다른 방향으로 배경 UV를 밀어서 샘플링
    vec2 refractOffset = (random(m_cellId) - 0.5) * uRefractAmount;

    // 색수차: R/G/B 를 굴절 방향으로 조금씩 더/덜 밀어서 따로 샘플 → 경계에서 색이 갈라짐
    vec2 ca = refractOffset * uAberration;
    float r = texture2D(uTexture, vUv + refractOffset + ca).r;
    float g = texture2D(uTexture, vUv + refractOffset     ).g;
    float b = texture2D(uTexture, vUv + refractOffset - ca).b;
    vec3 color = vec3(r, g, b);

    // 경계 근처(m_edge 작음)를 균열선으로: 푸른빛을 위에 덧칠
    float crack = 1.0 - smoothstep(0.0, uCrackWidth, m_edge);
    color += crack * uCrackBrightness * uCrackColor;

    gl_FragColor = vec4(color, 1.0);

    
}
