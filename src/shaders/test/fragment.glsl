varying vec2 vUv;

uniform float uTime;
uniform float uGridSize;
uniform float uRefractAmount;
uniform sampler2D uTexture;
uniform float uCrackWidth;
uniform float uCrackBrightness;
uniform float uAberration;
uniform vec3 uCrackColor;
uniform float uImpactRadius;
uniform float uParticleDensity;
uniform float uParticleAmount;


vec2 random(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));

    return fract(sin(p) * 43758.5453);
}

// 떠다니는 유리 가루: 촘촘한 격자 칸마다 작은 반짝이 점을 박는다
float particles(vec2 p, float density)
{
    vec2 gv = p * density;
    vec2 id = floor(gv);
    vec2 f  = fract(gv);

    float result = 0.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offs = vec2(float(x), float(y));
            vec2 cellId = id + offs;

            vec2 pos  = random(cellId);                 // 칸 안 점 위치 0~1
            float exists = step(0.55, random(cellId + 13.0).x); // 일부 칸만 (확률)
            float radius = mix(0.02, 0.07, random(cellId + 5.0).y); // 점 크기 랜덤
            float bright = mix(0.4, 1.0, random(cellId + 7.0).x);   // 밝기 랜덤

            float d = length(f - (offs + pos));
            result += exists * bright * smoothstep(radius, 0.0, d);
        }
    }
    return result;
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
    // 중앙 충격: 화면 중앙=1, 바깥으로 갈수록 0 (충격이 가운데서 가장 셈)
    float impact = 1.0 - smoothstep(0.0, uImpactRadius, length(vUv - 0.5));

    vec2 refractOffset = (random(m_cellId) - 0.5) * uRefractAmount * impact;

    // 색수차: R/G/B 를 굴절 방향으로 조금씩 더/덜 밀어서 따로 샘플 → 경계에서 색이 갈라짐
    vec2 ca = refractOffset * uAberration;
    float r = texture2D(uTexture, vUv + refractOffset + ca).r;
    float g = texture2D(uTexture, vUv + refractOffset     ).g;
    float b = texture2D(uTexture, vUv + refractOffset - ca).b;
    vec3 color = vec3(r, g, b);

    // 경계 근처(m_edge 작음)를 균열선으로: 푸른빛을 위에 덧칠
    float crack = 1.0 - smoothstep(0.0, uCrackWidth, m_edge);
    color += crack * uCrackBrightness * uCrackColor * impact;

    // 떠다니는 유리 가루 (균열 색조로 반짝)
    float dust = particles(vUv, uParticleDensity);
    color += dust * uParticleAmount * uCrackColor;

    gl_FragColor = vec4(color, 1.0);

    
}
