import { useEffect } from 'react';
import { useRouter } from 'next/router';

export default function Welcome() {
  const router = useRouter();

  // Auto redirect after 4 seconds
  useEffect(() => {
    const timer = setTimeout(() => {
      router.push('/');
    }, 4000);
    return () => clearTimeout(timer);
  }, [router]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-blue-50 dark:bg-gray-900 text-center p-4 transition-all duration-500">
      <h1 className="text-6xl font-bold text-blue-700 dark:text-blue-400 mb-4 animate-fadeIn">OcuHub</h1>
      <p className="text-xl text-blue-500 dark:text-blue-300 mb-8 animate-fadeIn delay-100">Ophthalmology Intelligence</p>
      <button
        onClick={() => router.push('/')}
        className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition dark:bg-blue-500 dark:hover:bg-blue-600"
      >
        Explore Now
      </button>
    </div>
  );
}

// Add this to your globals.css or tailwind.config.js to enable fadeIn
// .animate-fadeIn {
//   @apply opacity-0 animate-[fadeIn_1s_ease-in-out_forwards];
// }
// @keyframes fadeIn {
//   to { opacity: 1; }
// }
