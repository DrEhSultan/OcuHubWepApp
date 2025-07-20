import Head from 'next/head';
import Link from 'next/link';

export default function Home() {
  return (
    <>
      <Head>
        <title>OcuHub – Ophthalmology Intelligence Platform</title>
        <meta name="description" content="OcuHub is a digital platform designed for ophthalmologists, optometrists, and eye care professionals. It offers clinical calculators, diagnostic tools, vision tests, and AI-powered features to assist in daily medical decision-making." />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="contact" content="admin@ocuhub.com" />
        <link rel="icon" href="/logo.svg" />

        {/* Open Graph */}
        <meta property="og:title" content="OcuHub - Ophthalmology Intelligence Platform" />
        <meta property="og:description" content="OcuHub is a digital platform designed for ophthalmologists, optometrists, and eye care professionals. It offers clinical calculators, diagnostic tools, vision tests, and AI-powered features to assist in daily medical decision-making." />
        <meta property="og:image" content="https://ocuhub.com/logo.png" />
        <meta property="og:url" content="https://ocuhub.com" />
        <meta property="og:type" content="website" />

        {/* Twitter */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="OcuHub - Ophthalmology Intelligence Platform" />
        <meta name="twitter:description" content="OcuHub is a digital platform designed for ophthalmologists, optometrists, and eye care professionals. It offers clinical calculators, diagnostic tools, vision tests, and AI-powered features to assist in daily medical decision-making." />
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
              logo: "https://ocuhub.com/logo.svg",
              address: {
                "@type": "PostalAddress",
                addressRegion: "Delaware",
                addressCountry: "United States"
              },
              description: "OcuHub is a digital platform designed for ophthalmologists, optometrists, and eye care professionals. It offers clinical calculators, diagnostic tools, vision tests, and AI-powered features to assist in daily medical decision-making."
            }),
          }}
        />
      </Head>

      <div className="flex flex-col min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div className="flex items-center">
                <img src="/logo.svg" alt="OcuHub Logo" className="w-10 h-10 mr-3" />
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">OcuHub</h1>
                  <p className="text-sm text-gray-500">OcuHub Technologies LLC</p>
                </div>
              </div>
              <div className="text-sm text-gray-500">
                Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-600 hover:text-blue-800">admin@ocuhub.com</a>
              </div>
            </div>
          </div>
        </header>

        <main className="flex-1">
          {/* Hero Section */}
          <section className="bg-white py-16">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <img src="/logo.svg" alt="OcuHub Logo" className="w-32 h-32 mx-auto mb-8" />
              <h1 className="text-5xl font-bold text-gray-900 mb-6">
                OcuHub
              </h1>
              <p className="text-2xl text-blue-600 font-semibold mb-8">
                Ophthalmology Intelligence Platform
              </p>
              
              {/* Main Description */}
              <div className="max-w-4xl mx-auto">
                <p className="text-xl text-gray-700 leading-relaxed mb-8">
                  OcuHub is a comprehensive digital platform designed specifically for ophthalmologists, optometrists, and eye care professionals. Our platform provides essential tools and resources to enhance clinical decision-making and improve patient care.
                </p>
              </div>

              {/* Store Buttons */}
              <div className="flex justify-center gap-6 mb-12">
                <a href="https://play.google.com/store/apps/details?id=com.ocuhub.app" target="_blank" rel="noopener noreferrer" className="transition-transform hover:scale-105">
                  <img src="/google-play-badge.png" alt="Get it on Google Play" className="h-14" />
                </a>
                <a href="#" target="_blank" rel="noopener noreferrer" className="transition-transform hover:scale-105">
                  <img src="/app-store-badge.png" alt="Download on the App Store" className="h-14 opacity-50 cursor-not-allowed" />
                </a>
              </div>
            </div>
          </section>

          {/* Features Section */}
          <section className="bg-gray-50 py-16">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">
                What OcuHub Offers
              </h2>
              
              <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
                {/* Clinical Calculators */}
                <div className="bg-white p-6 rounded-lg shadow-md">
                  <div className="text-blue-600 text-3xl mb-4">🧮</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">Clinical Calculators</h3>
                  <p className="text-gray-600">
                    Access to essential ophthalmology calculators for IOL power, glaucoma risk assessment, and more.
                  </p>
                </div>

                {/* Diagnostic Tools */}
                <div className="bg-white p-6 rounded-lg shadow-md">
                  <div className="text-blue-600 text-3xl mb-4">🔍</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">Diagnostic Tools</h3>
                  <p className="text-gray-600">
                    Advanced diagnostic tools to assist in eye examination and disease detection.
                  </p>
                </div>

                {/* Vision Tests */}
                <div className="bg-white p-6 rounded-lg shadow-md">
                  <div className="text-blue-600 text-3xl mb-4">👁️</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">Vision Tests</h3>
                  <p className="text-gray-600">
                    Comprehensive vision testing tools for accurate patient assessment and monitoring.
                  </p>
                </div>

                {/* AI-Powered Features */}
                <div className="bg-white p-6 rounded-lg shadow-md">
                  <div className="text-blue-600 text-3xl mb-4">🤖</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">AI-Powered Features</h3>
                  <p className="text-gray-600">
                    Intelligent features powered by artificial intelligence to enhance clinical decision-making.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Purpose Section */}
          <section className="bg-white py-16">
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <h2 className="text-3xl font-bold text-gray-900 mb-8">
                Our Mission
              </h2>
              <p className="text-lg text-gray-700 leading-relaxed mb-6">
                OcuHub is dedicated to empowering eye care professionals with cutting-edge digital tools that streamline their workflow, improve diagnostic accuracy, and enhance patient outcomes. Our platform serves as a comprehensive ecosystem that brings together the latest advances in ophthalmology technology and artificial intelligence.
              </p>
              <p className="text-lg text-gray-700 leading-relaxed">
                Whether you're a practicing ophthalmologist, optometrist, or eye care professional, OcuHub provides the tools you need to deliver exceptional patient care in today's digital healthcare environment.
              </p>
            </div>
          </section>

          {/* Target Audience */}
          <section className="bg-gray-50 py-16">
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <h2 className="text-3xl font-bold text-gray-900 mb-8">
                Designed for Eye Care Professionals
              </h2>
              <div className="grid md:grid-cols-3 gap-8">
                <div className="text-center">
                  <div className="text-blue-600 text-4xl mb-4">👨‍⚕️</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">Ophthalmologists</h3>
                  <p className="text-gray-600">Specialized tools for comprehensive eye care and surgical planning</p>
                </div>
                <div className="text-center">
                  <div className="text-blue-600 text-4xl mb-4">👩‍⚕️</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">Optometrists</h3>
                  <p className="text-gray-600">Essential diagnostic and assessment tools for primary eye care</p>
                </div>
                <div className="text-center">
                  <div className="text-blue-600 text-4xl mb-4">🏥</div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">Eye Care Teams</h3>
                  <p className="text-gray-600">Collaborative tools for comprehensive patient care management</p>
                </div>
              </div>
            </div>
          </section>
        </main>

        {/* Footer */}
        <footer className="bg-gray-800 text-white py-8">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center">
              <p className="text-lg mb-4">&copy; {new Date().getFullYear()} OcuHub Technologies LLC. All rights reserved.</p>
              <div className="flex justify-center gap-6 mb-4">
                <Link href="/privacy-policy" className="text-blue-300 hover:text-white underline">Privacy Policy</Link>
                <Link href="/terms-of-service" className="text-blue-300 hover:text-white underline">Terms of Service</Link>
              </div>
              <div className="text-sm text-gray-400 space-y-1">
                <p>Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-300 hover:text-white">admin@ocuhub.com</a></p>
                <p>OcuHub Technologies LLC</p>
                <p>Delaware, United States</p>
              </div>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}