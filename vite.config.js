import { fileURLToPath } from 'url'
import { dirname, resolve } from 'path'
import restart from 'vite-plugin-restart'
import glsl from 'vite-plugin-glsl'

const __dirname = dirname(fileURLToPath(import.meta.url))

export default {
    root: 'src/',
    publicDir: '../static/',
    base: './',
    server:
    {
        host: true, // Open to local network and display URL
        open: !('SANDBOX_URL' in process.env || 'CODESANDBOX_HOST' in process.env) // Open if it's not a CodeSandbox
    },
    build:
    {
        outDir: '../dist', // Output in the dist/ folder
        emptyOutDir: true, // Empty the folder first
        sourcemap: true, // Add sourcemap
        rollupOptions:
        {
            // 멀티 페이지: 허브 + 패턴별 페이지를 각각 빌드 엔트리로 등록
            input:
            {
                main: resolve(__dirname, 'src/index.html'),
                glass: resolve(__dirname, 'src/glass/index.html'),
                dottedBackground: resolve(__dirname, 'src/dotted-background/index.html')
            }
        }
    },
    plugins:
    [
        restart({ restart: [ '../static/**', ] }), // Restart server on static file change
        glsl() // Handle shader files
    ]
}