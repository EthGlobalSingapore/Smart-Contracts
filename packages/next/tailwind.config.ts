/** @type {import('tailwindcss').Config} */
import { withAccountKitUi } from "@account-kit/react/tailwind";

export default withAccountKitUi({
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
});
