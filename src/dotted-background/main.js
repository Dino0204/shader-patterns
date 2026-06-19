import * as THREE from 'three'
import GUI from 'lil-gui'
import { createDottedBackground } from './pattern.js'

/**
 * Base
 */
const gui = new GUI()
const canvas = document.querySelector('canvas.webgl')

// 패턴(씬·카메라·머티리얼)은 공용 팩토리에서 생성
const pattern = createDottedBackground()
const { scene, camera, material } = pattern

// 컬러피커용 디버그 객체
const debugObject = {
    dotColor: '#000000',
    bgColor: '#ffffff'
}

// Debug controls
gui.add(material.uniforms.uGridSize, 'value', 20, 200, 1).name('Grid Size')
gui.add(material.uniforms.uDensityPower, 'value', 1, 6, 0.1).name('Density Power')
gui.add(material.uniforms.uJitter, 'value', 0, 1.5, 0.01).name('Jitter')
gui.addColor(debugObject, 'dotColor').name('Dot Color').onChange(() =>
{
    material.uniforms.uDotColor.value.set(debugObject.dotColor)
})
gui.addColor(debugObject, 'bgColor').name('Background').onChange(() =>
{
    material.uniforms.uBgColor.value.set(debugObject.bgColor)
})

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
pattern.setSize(sizes.width, sizes.height)
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

window.addEventListener('resize', () =>
{
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    pattern.setSize(sizes.width, sizes.height)

    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()

    pattern.update(elapsedTime)
    renderer.render(scene, camera)

    window.requestAnimationFrame(tick)
}

tick()
