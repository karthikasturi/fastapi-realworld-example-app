/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "./public/index.html"
  ],
  theme: {
    extend: {
      colors: {
        'conduit-green': '#5cb85c',
        'conduit-green-dark': '#449d44',
        'conduit-green-light': '#6fc76f',
      },
      fontFamily: {
        'titillium': ['Titillium Web', 'sans-serif'],
        'source-serif': ['Source Serif Pro', 'serif'],
        'merriweather': ['Merriweather Sans', 'sans-serif'],
        'source-sans': ['Source Sans Pro', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
