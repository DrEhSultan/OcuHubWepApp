import Head from 'next/head';
import Link from 'next/link';

export default function Home() {
  return (
    <>
      <Head>
        <title>OcuHub – Ophthalmology Intelligence</title>
        <meta name="description" content="Ophthalmology Intelligence. Delivered Simply." />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        {/* Contact meta for SEO */}
        <meta name="contact" content="admin@ocuhub.com" />

        {/* Favicon */}
        <link rel="icon" href="/logo.png" />

        {/* Open Graph Tags */}
        <meta property="og:title" content="OcuHub" />
        <meta property="og:description" content="Ophthalmology Intelligence. Delivered Simply." />
        <meta property="og:image" content="https://ocuhub.com/logo.png" />
        <meta property="og:url" content="https://ocuhub.com" />
        <meta property="og:type" content="website" />

        {/* Twitter Card */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="OcuHub" />
        <meta name="twitter:description" content="Ophthalmology Intelligence. Delivered Simply." />
        <meta name="twitter:image" content="https://ocuhub.com/logo.png" />

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
              logo: "https://ocuhub.com/logo.png"
            }),
          }}
        />
      </Head>

      <main className="flex flex-col items-center justify-center min-h-screen px-4 py-8 bg-gray-50">
        <img src="/logo.png" alt="OcuHub Logo" className="w-32 h-32 mb-4" />
        <h1 className="text-4xl font-bold text-center text-gray-800">OcuHub</h1>
        <p className="mt-4 text-center text-gray-600 text-lg">
          Ophthalmology Intelligence. Delivered Simply.
        </p>

        <div className="mt-8 flex gap-4">
          <Link href="/privacy-policy" className="text-blue-500 underline">Privacy Policy</Link>
          <Link href="/terms-of-service" className="text-blue-500 underline">Terms of Service</Link>
        </div>
      </main>

      <footer className="text-center text-gray-400 text-sm mt-10 mb-4">
        <div>&copy; {new Date().getFullYear()} OcuHub. All rights reserved.</div>
        <div className="mt-2">
          Contact us at: <a href="mailto:admin@ocuhub.com" className="text-blue-400">admin@ocuhub.com</a>
        </div>
      </footer>
    </>
  );
}