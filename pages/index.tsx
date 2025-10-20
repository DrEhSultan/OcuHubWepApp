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
        
        {/* Favicon Configuration */}
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/logo.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/logo.png" />
        <link rel="shortcut icon" href="/favicon.ico" />
        <meta name="msapplication-TileImage" content="/logo.png" />
        <meta name="msapplication-TileColor" content="#2563eb" />
        
        {/* Canonical URL */}
        <link rel="canonical" href="https://ocuhub.com" />

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

      <div className="flex flex-col min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50">
        {/* Header */}
        <header className="bg-white/80 backdrop-blur-md shadow-soft border-b border-gray-100 sticky top-0 z-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-4 sm:py-6">
              <div className="flex items-center gap-3">
                <img src="/logo.svg" alt="OcuHub Logo" className="w-8 h-8 sm:w-10 sm:h-10 transition-transform hover:scale-110" />
                <div>
                  <h1 className="text-xl sm:text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">OcuHub</h1>
                  <p className="text-xs sm:text-sm text-gray-600">OcuHub Technologies LLC</p>
                </div>
              </div>
              <div className="hidden sm:block text-sm text-gray-600">
                Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-600 hover:text-blue-700 font-medium transition-colors">admin@ocuhub.com</a>
              </div>
            </div>
          </div>
        </header>

        <main className="flex-1">
          {/* Hero Section */}
          <section className="relative bg-gradient-to-br from-white via-blue-50 to-indigo-50 py-12 sm:py-20 overflow-hidden">
            {/* Decorative background elements */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
              <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse"></div>
              <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-indigo-200 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse" style={{animationDelay: '1s'}}></div>
            </div>

            <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <img src="/logo.svg" alt="OcuHub Logo" className="w-24 h-24 sm:w-32 sm:h-32 mx-auto mb-6 sm:mb-8 drop-shadow-xl animate-fadeIn" />
              <h1 className="hero-title text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 sm:mb-6 animate-fadeIn">
                OcuHub
              </h1>
              <p className="text-xl sm:text-2xl lg:text-3xl bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent font-bold mb-6 sm:mb-10 animate-fadeIn">
                Ophthalmology Intelligence Platform
              </p>

              {/* Main Description */}
              <div className="max-w-4xl mx-auto mb-8 sm:mb-12">
                <p className="text-base sm:text-lg lg:text-xl text-gray-700 leading-relaxed px-4 sm:px-6 animate-fadeIn">
                  OcuHub is a comprehensive digital platform designed specifically for ophthalmologists, optometrists, and eye care professionals. Our platform provides essential tools and resources to enhance clinical decision-making and improve patient care.
                </p>
              </div>

              {/* Store Buttons */}
              <div className="flex flex-col sm:flex-row justify-center items-center gap-4 sm:gap-6 mb-8 sm:mb-12 px-4 animate-fadeIn">
                <a href="https://play.google.com/store/apps/details?id=com.ocuhub.OcuHub&hl=en-US&ah=aWUDqsiuOoiH3wn2qJRT_v4PMpc" target="_blank" rel="noopener noreferrer" className="transition-all hover:scale-105 hover:shadow-glow w-full sm:w-auto max-w-[200px]">
                  <img src="/google-play-badge.png" alt="Get it on Google Play" className="h-12 sm:h-14 w-full object-contain" />
                </a>
                <a href="#" target="_blank" rel="noopener noreferrer" className="transition-all hover:scale-105 opacity-50 cursor-not-allowed w-full sm:w-auto max-w-[200px]">
                  <img src="/app-store-badge.png" alt="Download on the App Store" className="h-12 sm:h-14 w-full object-contain" />
                </a>
              </div>
            </div>
          </section>

          {/* Features Section */}
          <section className="relative bg-gradient-to-b from-gray-50 to-white py-12 sm:py-20">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <h2 className="text-3xl sm:text-4xl font-bold text-center text-gray-900 mb-8 sm:mb-16">
                What OcuHub Offers
              </h2>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
                {/* Clinical Calculators */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">🧮</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Clinical Calculators</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Access to essential ophthalmology calculators for IOL power, glaucoma risk assessment, and more.
                  </p>
                </div>

                {/* Diagnostic Tools */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">🔍</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Diagnostic Tools</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Advanced diagnostic tools to assist in eye examination and disease detection.
                  </p>
                </div>

                {/* Vision Tests */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">👁️</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Vision Tests</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Comprehensive vision testing tools for accurate patient assessment and monitoring.
                  </p>
                </div>

                {/* AI-Powered Features */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">🤖</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">AI-Powered Features</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Intelligent features powered by artificial intelligence to enhance clinical decision-making.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Purpose Section */}
          <section className="relative bg-gradient-to-br from-white via-indigo-50 to-blue-50 py-12 sm:py-20 overflow-hidden">
            {/* Decorative elements */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none opacity-50">
              <div className="absolute top-20 right-10 w-40 h-40 bg-blue-300 rounded-full mix-blend-multiply filter blur-2xl"></div>
              <div className="absolute bottom-20 left-10 w-40 h-40 bg-indigo-300 rounded-full mix-blend-multiply filter blur-2xl"></div>
            </div>

            <div className="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-6 sm:mb-10">
                Our Mission
              </h2>
              <div className="space-y-6 sm:space-y-8">
                <p className="text-base sm:text-lg lg:text-xl text-gray-700 leading-relaxed bg-white/60 backdrop-blur-sm rounded-2xl p-6 sm:p-8 shadow-soft">
                  OcuHub is dedicated to empowering eye care professionals with cutting-edge digital tools that streamline their workflow, improve diagnostic accuracy, and enhance patient outcomes. Our platform serves as a comprehensive ecosystem that brings together the latest advances in ophthalmology technology and artificial intelligence.
                </p>
                <p className="text-base sm:text-lg lg:text-xl text-gray-700 leading-relaxed bg-white/60 backdrop-blur-sm rounded-2xl p-6 sm:p-8 shadow-soft">
                  Whether you're a practicing ophthalmologist, optometrist, or eye care professional, OcuHub provides the tools you need to deliver exceptional patient care in today's digital healthcare environment.
                </p>
              </div>
            </div>
          </section>

          {/* Target Audience */}
          <section className="bg-gradient-to-b from-gray-50 to-white py-12 sm:py-20">
            <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
              <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-8 sm:mb-16">
                Designed for Eye Care Professionals
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-10">
                <div className="group text-center bg-white rounded-2xl p-6 sm:p-8 shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-5xl sm:text-6xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">👨‍⚕️</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Ophthalmologists</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">Specialized tools for comprehensive eye care and surgical planning</p>
                </div>
                <div className="group text-center bg-white rounded-2xl p-6 sm:p-8 shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-5xl sm:text-6xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">👩‍⚕️</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Optometrists</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">Essential diagnostic and assessment tools for primary eye care</p>
                </div>
                <div className="group text-center bg-white rounded-2xl p-6 sm:p-8 shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-5xl sm:text-6xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300">🏥</div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Eye Care Teams</h3>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed">Collaborative tools for comprehensive patient care management</p>
                </div>
              </div>
            </div>
          </section>
        </main>

        {/* Footer */}
        <footer className="relative bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white py-10 sm:py-12 overflow-hidden">
          {/* Decorative gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-r from-blue-900/20 to-indigo-900/20"></div>

          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center">
              <p className="text-base sm:text-lg mb-6 font-medium">&copy; {new Date().getFullYear()} OcuHub Technologies LLC. All rights reserved.</p>

              <div className="flex flex-wrap justify-center gap-4 sm:gap-6 mb-6 sm:mb-8">
                <Link href="/privacy-policy" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Privacy Policy</Link>
                <Link href="/terms-of-service" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Terms of Service</Link>
                <Link href="/help-faq" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Help & FAQ</Link>
                <Link href="/data-deletion" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Data Deletion</Link>
              </div>

              <div className="text-sm sm:text-base text-gray-300 space-y-2 bg-gray-800/50 backdrop-blur-sm rounded-xl p-4 sm:p-6 inline-block">
                <p>Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-300 hover:text-blue-100 transition-colors font-medium">admin@ocuhub.com</a></p>
                <p className="font-medium">OcuHub Technologies LLC</p>
                <p>Delaware, United States</p>
              </div>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}
