import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'

/**
 * 유리 균열 패턴의 씬·카메라·머티리얼을 만든다.
 * 전체 페이지(main.js)와 허브 미리보기(hub.js)가 함께 사용한다.
 */
export function createGlass()
{
    const scene = new THREE.Scene()

    // Texture (static 폴더는 루트로 서빙됨 → '/image.png')
    const textureLoader = new THREE.TextureLoader()
    const backgroundTexture = textureLoader.load('/image.png', (texture) =>
    {
        // 이미지 로드 완료 후, 플레인을 이미지 비율에 맞춤 (찌그러짐 방지)
        const aspect = texture.image.width / texture.image.height
        mesh.scale.set(aspect, 1, 1)
    })

    const geometry = new THREE.PlaneGeometry(1, 1, 32, 32)

    const material = new THREE.ShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        side: THREE.DoubleSide,
        uniforms: {
            uTime: { value: 0 },
            uGridSize: { value: 5.0 },
            uRefractAmount: { value: 0.05 },
            uTexture: { value: backgroundTexture },
            uCrackWidth: { value: 0.05 },
            uCrackBrightness: { value: 1.0 },
            uAberration: { value: 0.5 },
            uCrackColor: { value: new THREE.Color('#99ccff') },
            uImpactRadius: { value: 0.6 },
            uParticleDensity: { value: 25.0 },
            uParticleAmount: { value: 1.0 }
        }
    })

    const mesh = new THREE.Mesh(geometry, material)
    scene.add(mesh)

    const camera = new THREE.PerspectiveCamera(75, 1, 0.1, 100)
    camera.position.set(0.25, - 0.25, 1)
    scene.add(camera)

    return {
        scene,
        camera,
        material,
        setSize(width, height)
        {
            camera.aspect = width / height
            camera.updateProjectionMatrix()
        },
        update(elapsedTime)
        {
            material.uniforms.uTime.value = elapsedTime
        }
    }
}
