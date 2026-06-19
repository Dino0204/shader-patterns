import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import { createGlass } from './pattern.js'

/**
 * Base
 */
const gui = new GUI()
const canvas = document.querySelector('canvas.webgl')

// 패턴(씬·카메라·머티리얼)은 공용 팩토리에서 생성
const pattern = createGlass()
const { scene, camera, material } = pattern

// 컬러피커용 디버그 객체
const debugObject = {
    crackColor: '#99ccff'
}

// Debug controls
gui.add(material.uniforms.uGridSize, 'value', 1, 30, 1).name('Grid Size')
gui.add(material.uniforms.uRefractAmount, 'value', 0, 0.3, 0.001).name('Refract')
gui.add(material.uniforms.uCrackWidth, 'value', 0, 0.2, 0.001).name('Crack Width')
gui.add(material.uniforms.uCrackBrightness, 'value', 0, 3, 0.01).name('Crack Bright')
gui.add(material.uniforms.uAberration, 'value', 0, 2, 0.01).name('Aberration')
gui.add(material.uniforms.uImpactRadius, 'value', 0.1, 1.5, 0.01).name('Impact Radius')
gui.add(material.uniforms.uParticleDensity, 'value', 5, 80, 1).name('Particle Density')
gui.add(material.uniforms.uParticleAmount, 'value', 0, 3, 0.01).name('Particle Amount')
gui.addColor(debugObject, 'crackColor').name('Crack Color').onChange(() =>
{
    material.uniforms.uCrackColor.value.set(debugObject.crackColor)
})

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    pattern.setSize(sizes.width, sizes.height)

    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Controls
 */
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
pattern.setSize(sizes.width, sizes.height)
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()

    pattern.update(elapsedTime)
    controls.update()
    renderer.render(scene, camera)

    window.requestAnimationFrame(tick)
}

tick()
