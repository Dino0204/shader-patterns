import * as THREE from 'three'
import { createGlass } from './glass/pattern.js'
import { createDottedBackground } from './dotted-background/pattern.js'

/**
 * 목록 페이지 라이브 미리보기
 *
 * three.js "Multiple Canvases, Multiple Scenes" 기법:
 * 화면을 덮는 단일 캔버스 + 단일 렌더러를 두고, 각 카드의 미리보기
 * 영역(getBoundingClientRect)에만 scissor + viewport 로 패턴을 그린다.
 * → WebGL 컨텍스트가 1개라 iframe 방식의 컨텍스트 제한 문제가 없다.
 *
 * 패턴 추가 방법: 아래 patterns 배열에 { id, create } 한 줄 추가 +
 * index.html 카드에 같은 id 를 data-preview 로 지정.
 */
const patterns = [
    { id: 'glass', create: createGlass },
    { id: 'dotted-background', create: createDottedBackground }
]

const canvas = document.querySelector('#preview-canvas')

const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true })
renderer.setClearColor(0x000000, 0) // 미리보기 영역 밖은 투명 → 페이지 배경이 비침

// data-preview 요소가 실제로 있는 패턴만 등록
const previews = patterns
    .map(({ id, create }) => ({
        elem: document.querySelector(`[data-preview="${id}"]`),
        pattern: create()
    }))
    .filter(({ elem }) => elem)

function resizeRendererToDisplaySize()
{
    const width = canvas.clientWidth
    const height = canvas.clientHeight
    if (canvas.width !== width || canvas.height !== height)
    {
        renderer.setSize(width, height, false)
    }
}

const clock = new THREE.Clock()

function render()
{
    const elapsedTime = clock.getElapsedTime()

    resizeRendererToDisplaySize()

    // 전체를 한 번 투명하게 비운 뒤, 영역별로 잘라서 그린다
    renderer.setScissorTest(false)
    renderer.clear()
    renderer.setScissorTest(true)

    for (const { elem, pattern } of previews)
    {
        const rect = elem.getBoundingClientRect()
        const { left, right, top, bottom, width, height } = rect

        const isOffscreen =
            bottom < 0 ||
            top > canvas.clientHeight ||
            right < 0 ||
            left > canvas.clientWidth

        if (isOffscreen) continue

        // WebGL 은 좌하단 원점 → Y 뒤집기
        const positiveYUpBottom = canvas.clientHeight - bottom

        renderer.setScissor(left, positiveYUpBottom, width, height)
        renderer.setViewport(left, positiveYUpBottom, width, height)

        pattern.setSize(width, height)
        pattern.update(elapsedTime)
        renderer.render(pattern.scene, pattern.camera)
    }

    window.requestAnimationFrame(render)
}

render()
