/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                skycosmic: {
                    light: '#00BFFF', // Sky Blue
                    DEFAULT: '#1E90FF', // Dodger Blue (?) or Deep Sky
                    dark: '#00008B', // Dark Blue
                }
            }
        },
    },
    plugins: [],
}
