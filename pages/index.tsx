import Head from 'next/head';
import Link from 'next/link';

export default function Home() {
  return (
    <>
      <Head>
        <title>OcuHub – Ophthalmology Intelligence</title>
        <meta name="description" content="Premium ecosystem for ophthalmologists, optometrists, and eye care professionals worldwide." />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="contact" content="admin@ocuhub.com" />
        <link rel="icon" href="/logo.svg" />

        {/* Open Graph */}
        <meta property="og:title" content="OcuHub" />
        <meta property="og:description" content="Premium ecosystem for ophthalmologists, optometrists, and eye care professionals worldwide." />
        <meta property="og:image" content="https://ocuhub.com/logo.png" />
        <meta property="og:url" content="https://ocuhub.com" />
        <meta property="og:type" content="website" />

        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="OcuHub" />
        <meta name="twitter:description" content="Premium ecosystem for ophthalmologists, optometrists, and eye care professionals worldwide." />
        <meta name="twitter:image" content="https://ocuhub.com/logo.svg" />

        {/* Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "Organization",
              name: "OcuHub",
              url: "https://ocuhub.com",
              email: "admin@ocuhub.com",
              logo: "https://ocuhub.com/logo.svg"
            }),
          }}
        />
      </Head>

      <div className="flex flex-col min-h-screen bg-gray-50">
        <main className="flex flex-col items-center justify-center flex-1 px-4 py-8">
          <img src="/logo.svg" alt="OcuHub Logo" className="w-32 h-32 mb-4" />
          <h1 className="text-4xl font-bold text-center text-gray-800">OcuHub</h1>

          {/* Slogan */}
          <p className="mt-2 text-center text-blue-600 text-lg font-semibold">
            Ophthalmology Intelligence<br />
            Delivered Simply.
          </p>

          {/* Description */}
          <p className="mt-4 text-center text-gray-600 text-lg max-w-xl leading-relaxed">
            Premium ecosystem for eye care professionals worldwide
          </p>

          {/* Store Buttons */}
          <div className="mt-6 flex gap-4">
            <a href="https://play.google.com/store/apps/details?id=com.ocuhub.app" target="_blank" rel="noopener noreferrer">
              <img src="/google-play-badge.png" alt="Get it on Google Play" className="h-12" />
            </a>
            <a href="#" target="_blank" rel="noopener noreferrer">
              <img src="/app-store-badge.png" alt="Download on the App Store" className="h-12 opacity-50 cursor-not-allowed" />
            </a>
          </div>

          {/* Policy Links */}
          <div className="mt-8 flex gap-4">
            <Link href="/privacy-policy" className="text-blue-500 underline">Privacy Policy</Link>
            <Link href="/terms-of-service" className="text-blue-500 underline">Terms of Service</Link>
          </div>
        </main>

        {/* Footer */}
        <footer className="text-center text-gray-400 text-sm p-4 pb-8 border-t border-gray-200">
  <div>&copy; {new Date().getFullYear()} OcuHub. All rights reserved.</div>
  <div className="mt-1">
    Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-400">admin@ocuhub.com</a>
  </div>
</footer>
      </div>
    </>
  );
}