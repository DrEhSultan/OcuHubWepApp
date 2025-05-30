// File: pages/index.tsx

import Head from 'next/head';
import Image from 'next/image';

export default function Home() {
  return (
    <>
      <Head>
        <title>OcuHub</title>
      </Head>
      <div className="min-h-screen flex flex-col bg-white dark:bg-gray-900 text-gray-800 dark:text-white">
        {/* Main Content */}
        <main className="flex-grow px-6 py-16 flex flex-col items-center justify-center text-center">
          {/* Logo */}
          <Image
            src="/logo.png"
            alt="OcuHub Logo"
            width={120}
            height={120}
            className="mb-6"
          />

          {/* Headline */}
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            OcuHub
          </h1>

          {/* Description */}
          <p className="text-lg md:text-xl mb-8 max-w-xl">
            Ophthalmology Intelligence, Delivered Simply
            <br />
            OcuHub is a premium ecosystem built for ophthalmologists, optometrists, orthoptists, and eye care professionals worldwide.
          </p>

          {/* App Store Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 mb-10">
            <a href="#" className="inline-block">
              <Image src="/google-play-badge.png" alt="Google Play" width={160} height={48} />
            </a>
            <a href="#" className="inline-block">
              <Image src="/app-store-badge.png" alt="App Store" width={160} height={48} />
            </a>
          </div>
        </main>

        {/* Footer */}
        <footer className="w-full text-center py-4 text-sm text-gray-500 dark:text-gray-400 border-t border-gray-200 dark:border-gray-700">
          <p>
            Contact us: <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>
          </p>
          <p>
            <a href="/privacy-policy" className="underline">Privacy Policy</a>
          </p>
        </footer>
      </div>
    </>
  );
}