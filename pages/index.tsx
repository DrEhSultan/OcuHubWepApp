// File: pages/index.tsx

import Head from 'next/head';
import Image from 'next/image';

export default function Home() {
  return (
    <>
      <Head>
        <title>OcuHub – Ophthalmology Intelligence</title>
      </Head>
      <main className="min-h-screen bg-white dark:bg-gray-900 text-gray-800 dark:text-white px-6 py-16 flex flex-col items-center justify-center text-center">
        {/* Logo */}
        <Image
          src="/logo.png" // ضع هنا مسار الشعار الخاص بك داخل مجلد public
          alt="OcuHub Logo"
          width={120}
          height={120}
          className="mb-6"
        />

        {/* Headline */}
        <h1 className="text-4xl md:text-5xl font-bold mb-4">OcuHub – Ophthalmology Intelligence</h1>

        {/* Description */}
        <p className="text-lg md:text-xl mb-8 max-w-xl">
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

        {/* Contact Info */}
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Contact us: <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>
        </p>
      </main>
    </>
  );
}
