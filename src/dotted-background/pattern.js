import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'

/**
 * 점 배경 패턴의 씬·카메라·머티리얼을 만든다.
 * 전체 페이지(main.js)와 허브 미리보기(hub.js)가 함께 사용한다.
 */
export function createDottedBackground()
{
    const scene = new THREE.Scene()

    // 풀스크린 쿼드
    const geometry = new THREE.PlaneGeometry(2, 2)

    const material = new THREE.ShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        uniforms: {
            uTime: { value: 0 },
            uResolution: { value: new THREE.Vector2(1, 1) },
            uGridSize: { value: 100.0 },
            uDensityPower: { value: 2.0 },
            uJitter: { value: 0.6 },
            uDotColor: { value: new THREE.Color('#000000') },
            uBgColor: { value: new THREE.Color('#ffffff') }
        }
    })

    const mesh = new THREE.Mesh(geometry, material)
    scene.add(mesh)

    // 정사영 카메라 (풀스크린 쿼드용)
    const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1)
    scene.add(camera)

    return {
        scene,
        camera,
        material,
        setSize(width, height)
        {
            material.uniforms.uResolution.value.set(width, height)
        },
        update(elapsedTime)
        {
            material.uniforms.uTime.value = elapsedTime
        }
    }
}
