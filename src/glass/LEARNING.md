# 학습 기록 · 유리 균열(Voronoi 파편)

> 이 패턴은 인터랙티브 인터뷰 전에 만들어져, 코드(`fragment.glsl`) 기준으로 개념을 정리한 요약본이다.
> 새로 복습할 땐 `learn-by-asking` 스킬로 아래 개념을 질문화해서 다시 짚으면 좋다.
> 관련 파일: `fragment.glsl`, `pattern.js`, `main.js`

## 0. 효과 구성

이미지 위에 깨진 유리를 얹은 느낌. 다섯 겹이 쌓여 있다:
1. **Voronoi 파편** — 화면을 불규칙한 셀로 나눔
2. **균열선** — 셀 경계를 푸르게 그림
3. **굴절** — 파편마다 배경을 다른 방향으로 밀어 샘플
4. **색수차** — 굴절 방향으로 R/G/B를 갈라 샘플
5. **유리 가루** — 떠다니는 반짝이 점

## 1. 격자 + 랜덤 점 = Voronoi의 출발

- `vUv`를 `uGridSize`로 키운 뒤 `floor`(칸 ID) / `fract`(칸 안 위치)로 나눈다. (점 배경과 동일한 기초 — [dotted-background/LEARNING.md](../dotted-background/LEARNING.md) 참고)
- `random(cellId)`로 칸마다 고정된 점 하나를 배치. `hash`로 "일정한 불규칙성"을 만드는 원리는 점 배경과 같다.

## 2. 1차 패스 — 가장 가까운 점 찾기 (Voronoi)

```glsl
for (y,x in -1..1) {            // 주변 9칸 검사
    vec2 randomPoint = random(cellId + neighbor);
    float dist = length(diff);
    if (dist < m_dist) { ...이긴 점의 ID·벡터 기록 }
}
```
- 각 픽셀에서 **주변 9칸의 랜덤 점 중 가장 가까운 것**을 찾는다 → 화면이 불규칙한 셀(파편)로 나뉜다. 이게 Voronoi.
- `min()` 대신 `if`를 쓴 이유: 단순 최소 거리뿐 아니라 **누가 이겼는지(`m_cellId`, `m_diff`)**까지 기록해야 다음 단계에 쓸 수 있기 때문.

## 3. 2차 패스 — 균열선(셀 경계)까지의 거리

```glsl
m_edge = min(m_edge, dot(0.5*(m_diff+diff), normalize(diff - m_diff)));
```
- 내 점과 이웃 점의 **수직이등분선 = 셀 경계**까지의 거리를 잰다.
- 자기 자신(이긴 점)은 `dot(...) > 0.0001` 조건으로 건너뛴다.
- `m_edge`가 작은 곳 = 경계 근처 = 균열선.

## 4. 굴절 + 색수차

```glsl
float impact = 1.0 - smoothstep(0.0, uImpactRadius, length(vUv - 0.5));
vec2 refractOffset = (random(m_cellId) - 0.5) * uRefractAmount * impact;
```
- **파편(`m_cellId`)마다 다른 방향**으로 배경 UV를 밀어 샘플 → 깨진 유리의 굴절.
- `impact`: 화면 중앙=1, 바깥=0. 충격이 가운데서 가장 세게 든 것처럼 굴절을 중앙에 집중.
- **색수차**: R/G/B를 굴절 방향으로 조금씩 더/덜 밀어 따로 샘플 → 경계에서 색이 갈라진다.

## 5. 균열선 + 유리 가루 덧칠

```glsl
float crack = 1.0 - smoothstep(0.0, uCrackWidth, m_edge);
color += crack * uCrackBrightness * uCrackColor * impact;
color += particles(vUv, uParticleDensity) * uParticleAmount * uCrackColor;
```
- 경계(`m_edge` 작음)를 균열 색으로 덧칠. `impact`로 중앙에서 더 밝게.
- `particles()`: 또 다른 촘촘한 격자에 확률적으로 반짝이 점을 박아 떠다니는 유리 가루 표현.

## 핵심 도구 요약

| 도구 | 역할 |
|------|------|
| `floor`/`fract` | 격자 분할 (점 배경과 공유) |
| `random(cellId)` | 칸별 고정 난수 → 점 위치/굴절 방향 |
| 9칸 루프 + `if` | 가장 가까운 점 찾기 = Voronoi |
| 수직이등분선 거리 | 셀 경계 = 균열선 |
| `smoothstep` | 균열 두께·중앙 충격 감쇠 |
| `texture2D` 오프셋 샘플 | 굴절 + 색수차 |

## 복습용 break-it 질문

- 1차 패스에서 `if`를 `m_dist = min(m_dist, dist)`로 바꾸면 왜 균열·굴절이 깨질까?
- `impact`를 1.0 상수로 고정하면 화면이 어떻게 변할까?
- `random(m_cellId)`를 `random(cellId)`로 바꾸면(파편 ID 대신 현재 칸 ID) 굴절이 어떻게 달라질까?
