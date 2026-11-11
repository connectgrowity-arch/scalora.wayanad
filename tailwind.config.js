/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        bg: '#0B0A0F',
        brand: '#5C6CFF',
        ink: '#F4F3F8',
        muted: '#9a98a8',
        card: '#13121a',
        line: 'rgba(255, 255, 255, 0.09)',
      },
      fontFamily: {
        // Space Grotesk: Headlines, display, numbers (Bold 700 / Medium 500)
        display: ['"Space Grotesk"', 'Sora', 'system-ui', '-apple-system', 'sans-serif'],
        heading: ['"Space Grotesk"', 'Sora', 'system-ui', '-apple-system', 'sans-serif'],
        // Inter: Body, UI, captions, documents (Regular 400 / SemiBold 600)
        sans: ['Inter', 'Manrope', 'system-ui', '-apple-system', 'sans-serif'],
      },
      letterSpacing: {
        'display': '-0.03em', // -3% tracking for Display
        'h1': '-0.02em',      // -2% tracking for Heading 1
        'h2': '-0.01em',      // -1% tracking for Heading 2
        'body': '0em',        // 0% tracking for Body
        'label': '0.08em',    // +8% tracking for Labels
      },
      lineHeight: {
        'display': '1.0',     // 100% line height
        'h1': '1.1',          // 110% line height
        'h2': '1.2',          // 120% line height
        'body': '1.55',       // 150-160% line height
      },
      animation: {
        'marquee': 'marquee 40s linear infinite',
        'marquee-reverse': 'marquee-reverse 40s linear infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'shimmer-bar': 'shimmerBar 3s ease-in-out infinite alternate',
      },
      keyframes: {
        marquee: {
          '0%': { transform: 'translateX(0%)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        'marquee-reverse': {
          '0%': { transform: 'translateX(-50%)' },
          '100%': { transform: 'translateX(0%)' },
        },
        shimmerBar: {
          '0%': { transform: 'translateX(0)', opacity: '1' },
          '100%': { transform: 'translateX(18px)', opacity: '0.6' },
        }
      }
    },
  },
  plugins: [],
}
