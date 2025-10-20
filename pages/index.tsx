import Head from 'next/head';
import Link from 'next/link';
import { useState } from 'react';

export default function Home() {
  const [showComingSoonPopup, setShowComingSoonPopup] = useState(false);

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

              {/* Store Buttons - Enhanced & Prominent */}
              <div className="flex flex-col sm:flex-row justify-center items-center gap-6 sm:gap-8 mb-8 sm:mb-12 px-4 animate-fadeIn">
                {/* Google Play Store Button - Active */}
                <a
                  href="https://play.google.com/store/apps/details?id=com.ocuhub.OcuHub&hl=en-US&ah=aWUDqsiuOoiH3wn2qJRT_v4PMpc"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group relative w-full sm:w-auto max-w-[240px]"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-green-400 to-blue-500 rounded-2xl blur-lg opacity-50 group-hover:opacity-75 transition-opacity duration-300"></div>
                  <div className="relative bg-black rounded-2xl p-4 sm:p-5 transform transition-all duration-300 group-hover:scale-105 group-hover:shadow-2xl shadow-glow">
                    <div className="flex items-center gap-4">
                      <div className="flex-shrink-0">
                        <svg className="w-10 h-10 sm:w-12 sm:h-12" viewBox="0 0 24 24" fill="none">
                          <path d="M3 20.5V3.5C3 2.91 3.34 2.39 3.84 2.15L13.69 12L3.84 21.85C3.34 21.6 3 21.09 3 20.5Z" fill="#00D7FF"/>
                          <path d="M16.81 15.12L6.05 21.34L14.54 12.85L16.81 15.12Z" fill="#FFC600"/>
                          <path d="M3.84 2.15L6.05 2.66L14.54 11.15L6.05 2.66L3.84 2.15Z" fill="#FF3E00"/>
                          <path d="M16.81 8.88L19.96 10.68C20.62 11.04 21 11.65 21 12.34C21 13.04 20.62 13.65 19.96 14L16.81 15.81L14.54 13.54L16.81 8.88Z" fill="#00E667"/>
                        </svg>
                      </div>
                      <div className="text-left">
                        <div className="text-xs sm:text-sm text-gray-300 font-normal">GET IT ON</div>
                        <div className="text-lg sm:text-xl font-bold text-white">Google Play</div>
                      </div>
                    </div>
                  </div>
                </a>

                {/* App Store Button - Coming Soon */}
                <button
                  onClick={() => setShowComingSoonPopup(true)}
                  className="group relative w-full sm:w-auto max-w-[240px] cursor-pointer"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-500 rounded-2xl blur-lg opacity-30 group-hover:opacity-50 transition-opacity duration-300"></div>
                  <div className="relative bg-gradient-to-br from-gray-700 to-gray-800 rounded-2xl p-4 sm:p-5 transform transition-all duration-300 group-hover:scale-105 shadow-lg border-2 border-gray-600">
                    <div className="flex items-center gap-4">
                      <div className="flex-shrink-0">
                        <svg className="w-10 h-10 sm:w-12 sm:h-12" viewBox="0 0 24 24" fill="none">
                          <path d="M18.71 19.5C17.88 20.74 17 21.95 15.66 21.97C14.32 22 13.89 21.18 12.37 21.18C10.84 21.18 10.37 21.95 9.09997 22C7.78997 22.05 6.79997 20.68 5.95997 19.47C4.24997 17 2.93997 12.45 4.69997 9.39C5.56997 7.87 7.12997 6.91 8.81997 6.88C10.1 6.86 11.32 7.75 12.11 7.75C12.89 7.75 14.37 6.68 15.92 6.84C16.57 6.87 18.39 7.1 19.56 8.82C19.47 8.88 17.39 10.1 17.41 12.63C17.44 15.65 20.06 16.66 20.09 16.67C20.06 16.74 19.67 18.11 18.71 19.5ZM13 3.5C13.73 2.67 14.94 2.04 15.94 2C16.07 3.17 15.6 4.35 14.9 5.19C14.21 6.04 13.07 6.7 11.95 6.61C11.8 5.46 12.36 4.26 13 3.5Z" fill="#FFFFFF" opacity="0.5"/>
                        </svg>
                      </div>
                      <div className="text-left">
                        <div className="text-xs sm:text-sm text-gray-400 font-normal">Download on the</div>
                        <div className="text-lg sm:text-xl font-bold text-gray-300">App Store</div>
                      </div>
                    </div>
                    <div className="absolute top-2 right-2 bg-yellow-500 text-black text-xs font-bold px-2 py-1 rounded-full">
                      SOON
                    </div>
                  </div>
                </button>
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
                  <div className="text-center">
                    <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300 inline-block">🧮</div>
                    <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Clinical Calculators</h3>
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed text-justify">
                    Access to essential ophthalmology calculators for IOL power, glaucoma risk assessment, and more.
                  </p>
                </div>

                {/* Diagnostic Tools */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-center">
                    <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300 inline-block">🔍</div>
                    <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Diagnostic Tools</h3>
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed text-justify">
                    Advanced diagnostic tools to assist in eye examination and disease detection.
                  </p>
                </div>

                {/* Vision Tests */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-center">
                    <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300 inline-block">👁️</div>
                    <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">Vision Tests</h3>
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed text-justify">
                    Comprehensive vision testing tools for accurate patient assessment and monitoring.
                  </p>
                </div>

                {/* AI-Powered Features */}
                <div className="group bg-white p-6 sm:p-8 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-2 border border-gray-100">
                  <div className="text-center">
                    <div className="text-4xl sm:text-5xl mb-4 sm:mb-6 filter group-hover:scale-110 transition-transform duration-300 inline-block">🤖</div>
                    <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-3 sm:mb-4">AI-Powered Features</h3>
                  </div>
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed text-justify">
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

        {/* Coming Soon Popup Modal */}
        {showComingSoonPopup && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fadeIn"
            onClick={() => setShowComingSoonPopup(false)}
          >
            <div
              className="relative bg-gradient-to-br from-white via-blue-50 to-indigo-50 dark:from-gray-800 dark:via-gray-700 dark:to-gray-800 rounded-3xl shadow-2xl max-w-md w-full p-8 sm:p-10 transform transition-all"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Close Button */}
              <button
                onClick={() => setShowComingSoonPopup(false)}
                className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>

              {/* Icon */}
              <div className="flex justify-center mb-6">
                <div className="relative">
                  <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full blur-xl opacity-50 animate-pulse"></div>
                  <div className="relative bg-gradient-to-br from-blue-500 to-indigo-600 rounded-full p-6">
                    <svg className="w-16 h-16 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
              </div>

              {/* Title */}
              <h3 className="text-3xl sm:text-4xl font-bold text-center mb-4 bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                Coming Soon!
              </h3>

              {/* Message */}
              <p className="text-center text-gray-700 dark:text-gray-300 text-base sm:text-lg mb-6 leading-relaxed">
                Our iOS app is currently in development and will be available on the App Store very soon. Stay tuned!
              </p>

              {/* App Store Icon */}
              <div className="flex justify-center mb-6">
                <div className="bg-white dark:bg-gray-700 rounded-2xl p-4 shadow-lg">
                  <svg className="w-16 h-16" viewBox="0 0 24 24" fill="none">
                    <path d="M18.71 19.5C17.88 20.74 17 21.95 15.66 21.97C14.32 22 13.89 21.18 12.37 21.18C10.84 21.18 10.37 21.95 9.09997 22C7.78997 22.05 6.79997 20.68 5.95997 19.47C4.24997 17 2.93997 12.45 4.69997 9.39C5.56997 7.87 7.12997 6.91 8.81997 6.88C10.1 6.86 11.32 7.75 12.11 7.75C12.89 7.75 14.37 6.68 15.92 6.84C16.57 6.87 18.39 7.1 19.56 8.82C19.47 8.88 17.39 10.1 17.41 12.63C17.44 15.65 20.06 16.66 20.09 16.67C20.06 16.74 19.67 18.11 18.71 19.5ZM13 3.5C13.73 2.67 14.94 2.04 15.94 2C16.07 3.17 15.6 4.35 14.9 5.19C14.21 6.04 13.07 6.7 11.95 6.61C11.8 5.46 12.36 4.26 13 3.5Z" fill="url(#appleGradient)"/>
                    <defs>
                      <linearGradient id="appleGradient" x1="4" y1="2" x2="20" y2="22" gradientUnits="userSpaceOnUse">
                        <stop stopColor="#667eea"/>
                        <stop offset="1" stopColor="#764ba2"/>
                      </linearGradient>
                    </defs>
                  </svg>
                </div>
              </div>

              {/* Info Box */}
              <div className="bg-blue-100 dark:bg-blue-900/30 rounded-xl p-4 mb-6 border border-blue-200 dark:border-blue-700">
                <p className="text-sm text-center text-blue-800 dark:text-blue-200">
                  <strong>Meanwhile,</strong> download our Android app from Google Play Store!
                </p>
              </div>

              {/* Action Button */}
              <button
                onClick={() => setShowComingSoonPopup(false)}
                className="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-bold py-4 px-6 rounded-xl transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl"
              >
                Got it, Thanks!
              </button>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
