import Head from 'next/head';
import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function Home() {
  const [showComingSoonPopup, setShowComingSoonPopup] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

  // Handle scroll for sticky header
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const handleScroll = () => {
        setIsScrolled(window.scrollY > 100);
      };
      window.addEventListener('scroll', handleScroll);
      return () => window.removeEventListener('scroll', handleScroll);
    }
  }, []);

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
        <header className={`bg-white/80 backdrop-blur-md shadow-soft border-b border-gray-100 sticky top-0 z-50 transition-all duration-300 ${isScrolled ? 'py-2' : 'py-0'}`}>
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-4 sm:py-6">
              <div className="flex items-center gap-3">
                <img src="/logo.svg" alt="OcuHub Logo" className="w-8 h-8 sm:w-10 sm:h-10 transition-transform hover:scale-110" />
                <div>
                  <h1 className="text-xl sm:text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">OcuHub</h1>
                  <p className={`text-xs sm:text-sm text-gray-600 transition-all duration-300 ${isScrolled ? 'opacity-0 h-0' : 'opacity-100'}`}>
                    OcuHub Technologies LLC
                  </p>
                </div>
              </div>

              {/* Download Buttons - Both always visible */}
              <div className="flex items-center gap-2">
                {/* Google Play Button - Always visible */}
                <a
                  href="https://play.google.com/store/apps/details?id=com.ocuhub.OcuHub&hl=en-US&ah=aWUDqsiuOoiH3wn2qJRT_v4PMpc"
                  target="_blank"
                  rel="noopener noreferrer"
                  className={`group flex items-center gap-2 bg-black hover:bg-gray-900 text-white rounded-full font-semibold transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105 ${
                    isScrolled ? 'px-4 py-2.5' : 'px-3 py-2 sm:px-4 sm:py-2.5'
                  }`}
                >
                  <svg className="w-5 h-5 sm:w-6 sm:h-6" viewBox="0 0 48 48" fill="none">
                    <path d="M6 4.5C6 3.12 6.67 1.95 7.68 1.5L27.38 24L7.68 46.5C6.67 46.05 6 44.88 6 43.5V4.5Z" fill="#00D9FF"/>
                    <path d="M33.62 31.74L12.1 45.68L29.08 27.7L33.62 31.74Z" fill="#FFCE00"/>
                    <path d="M7.68 1.5L12.1 2.32L29.08 20.3L12.1 2.32L7.68 1.5Z" fill="#FF3E00"/>
                    <path d="M33.62 16.26L39.92 20.36C41.24 21.08 42 22.3 42 23.68C42 25.08 41.24 26.3 39.92 27L33.62 31.1L29.08 26.56L33.62 16.26Z" fill="#00F076"/>
                  </svg>
                  <svg className="w-5 h-5 sm:w-6 sm:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                </a>

                {/* App Store Button - Always visible */}
                <button
                  onClick={() => setShowComingSoonPopup(true)}
                  className={`group flex items-center gap-2 bg-gradient-to-r from-gray-700 to-gray-800 hover:from-gray-800 hover:to-gray-900 text-white rounded-full font-semibold transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105 ${
                    isScrolled ? 'px-4 py-2.5' : 'px-3 py-2 sm:px-4 sm:py-2.5'
                  }`}
                >
                  <svg className="w-5 h-5 sm:w-6 sm:h-6" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18.71 19.5C17.88 20.74 17 21.95 15.66 21.97C14.32 22 13.89 21.18 12.37 21.18C10.84 21.18 10.37 21.95 9.09997 22C7.78997 22.05 6.79997 20.68 5.95997 19.47C4.24997 17 2.93997 12.45 4.69997 9.39C5.56997 7.87 7.12997 6.91 8.81997 6.88C10.1 6.86 11.32 7.75 12.11 7.75C12.89 7.75 14.37 6.68 15.92 6.84C16.57 6.87 18.39 7.1 19.56 8.82C19.47 8.88 17.39 10.1 17.41 12.63C17.44 15.65 20.06 16.66 20.09 16.67C20.06 16.74 19.67 18.11 18.71 19.5ZM13 3.5C13.73 2.67 14.94 2.04 15.94 2C16.07 3.17 15.6 4.35 14.9 5.19C14.21 6.04 13.07 6.7 11.95 6.61C11.8 5.46 12.36 4.26 13 3.5Z"/>
                  </svg>
                  <svg className="w-5 h-5 sm:w-6 sm:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                </button>
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
              <h1 className="hero-title text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 sm:mb-6 animate-fadeIn text-center">
                OcuHub
              </h1>
              <p className="text-xl sm:text-2xl lg:text-3xl bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent font-bold mb-6 sm:mb-10 animate-fadeIn text-center">
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
                        <svg className="w-10 h-10 sm:w-12 sm:h-12" viewBox="0 0 48 48" fill="none">
                          {/* Official Google Play Triangle - Blue */}
                          <path d="M6 4.5C6 3.12 6.67 1.95 7.68 1.5L27.38 24L7.68 46.5C6.67 46.05 6 44.88 6 43.5V4.5Z" fill="#00D9FF"/>
                          {/* Official Google Play Triangle - Yellow */}
                          <path d="M33.62 31.74L12.1 45.68L29.08 27.7L33.62 31.74Z" fill="#FFCE00"/>
                          {/* Official Google Play Triangle - Red */}
                          <path d="M7.68 1.5L12.1 2.32L29.08 20.3L12.1 2.32L7.68 1.5Z" fill="#FF3E00"/>
                          {/* Official Google Play Triangle - Green */}
                          <path d="M33.62 16.26L39.92 20.36C41.24 21.08 42 22.3 42 23.68C42 25.08 41.24 26.3 39.92 27L33.62 31.1L29.08 26.56L33.62 16.26Z" fill="#00F076"/>
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

          {/* App Gallery Section - Horizontal Scrollable */}
          <section className="relative bg-gradient-to-b from-gray-50 via-white to-gray-50 py-16 sm:py-24 overflow-hidden">
            {/* Animated Background */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none opacity-20">
              <div className="absolute top-1/4 left-0 w-96 h-96 bg-gradient-to-r from-blue-400 to-indigo-400 rounded-full mix-blend-multiply filter blur-3xl animate-pulse"></div>
              <div className="absolute bottom-1/4 right-0 w-96 h-96 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full mix-blend-multiply filter blur-3xl animate-pulse" style={{animationDelay: '2s'}}></div>
            </div>

            <div className="relative">
              {/* Section Header - Centered */}
              <div className="text-center mb-10 sm:mb-12 px-4">
                <div className="inline-block px-6 py-2 bg-gradient-to-r from-blue-100 to-indigo-100 rounded-full mb-4">
                  <span className="text-blue-700 font-bold text-sm sm:text-base">✨ App Features</span>
                </div>
                <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-4 text-center">
                  <span className="bg-gradient-to-r from-gray-900 via-blue-800 to-indigo-900 bg-clip-text text-transparent">
                    See OcuHub in Action
                  </span>
                </h2>
                <p className="text-base sm:text-lg text-gray-600 max-w-2xl mx-auto text-center">
                  Powerful tools designed for modern ophthalmology practice
                </p>
              </div>

              {/* Horizontal Scrollable Gallery */}
              <div className="relative mb-12">
                {/* Scroll Container */}
                <div className="overflow-x-auto scrollbar-hide px-4 sm:px-6 lg:px-8">
                  <div className="flex gap-4 sm:gap-6 pb-4">
                    {[
                      { src: '/screenshots/Home Screen.png', title: 'Dashboard', gradient: 'from-blue-500 to-cyan-500' },
                      { src: '/screenshots/7_Vision_Tools-removebg.png', title: 'Vision Tests', gradient: 'from-purple-500 to-pink-500' },
                      { src: '/screenshots/2_Decision-removebg.png', title: 'Clinical Tools', gradient: 'from-green-500 to-emerald-500' },
                      { src: '/screenshots/Retinoscopy-removebg.png', title: 'Diagnostics', gradient: 'from-orange-500 to-red-500' },
                      { src: '/screenshots/3_E_Chart_Controls-removebg.png', title: 'E-Chart', gradient: 'from-teal-500 to-blue-500' },
                      { src: '/screenshots/4_Kids_Fixation-removebg.png', title: 'Pediatric', gradient: 'from-pink-500 to-rose-500' },
                      { src: '/screenshots/astigmatic-fan.png', title: 'Astigmatism', gradient: 'from-indigo-500 to-purple-500' },
                      { src: '/screenshots/w4D.png', title: 'Worth 4 Dot', gradient: 'from-amber-500 to-orange-500' },
                    ].map((item, idx) => (
                      <div
                        key={idx}
                        onClick={() => setSelectedImage(item.src)}
                        className="group relative flex-shrink-0 cursor-pointer"
                        style={{ width: '200px' }}
                      >
                        <div className={`absolute -inset-2 bg-gradient-to-r ${item.gradient} rounded-2xl opacity-0 group-hover:opacity-30 blur-lg transition-all duration-300`}></div>
                        <div className="relative bg-white rounded-2xl p-2 shadow-lg hover:shadow-2xl transition-all duration-300 transform group-hover:scale-105">
                          {/* Phone-like Screenshot Container */}
                          <div className="relative bg-gray-900 rounded-xl overflow-hidden" style={{ aspectRatio: '9/19.5' }}>
                            <img
                              src={item.src}
                              alt={item.title}
                              className="w-full h-full object-contain bg-white"
                              loading="lazy"
                            />
                          </div>
                          {/* Title Below */}
                          <div className="text-center mt-3">
                            <h3 className="font-bold text-gray-900 text-sm">{item.title}</h3>
                            <div className={`mt-2 h-0.5 bg-gradient-to-r ${item.gradient} rounded-full mx-auto w-12 opacity-0 group-hover:opacity-100 transition-opacity duration-300`}></div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Scroll Hint */}
                <div className="text-center mt-4">
                  <p className="text-sm text-gray-500 flex items-center justify-center gap-2">
                    <svg className="w-4 h-4 animate-bounce" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                    Swipe to see more
                  </p>
                </div>
              </div>

              {/* Key Features - Centered */}
              <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mt-16">
                  <div className="text-center p-6 bg-white/50 backdrop-blur-sm rounded-2xl border border-gray-200 hover:border-blue-300 transition-colors duration-300">
                    <div className="inline-flex items-center justify-center w-14 h-14 bg-gradient-to-br from-blue-500 to-indigo-500 rounded-2xl mb-4 shadow-lg">
                      <span className="text-2xl">🧮</span>
                    </div>
                    <h3 className="font-bold text-gray-900 mb-2 text-center">Clinical Calculators</h3>
                    <p className="text-sm text-gray-600 text-justify">IOL power, risk assessment, and specialized ophthalmology formulas</p>
                  </div>

                  <div className="text-center p-6 bg-white/50 backdrop-blur-sm rounded-2xl border border-gray-200 hover:border-purple-300 transition-colors duration-300">
                    <div className="inline-flex items-center justify-center w-14 h-14 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl mb-4 shadow-lg">
                      <span className="text-2xl">👁️</span>
                    </div>
                    <h3 className="font-bold text-gray-900 mb-2 text-center">Vision Testing</h3>
                    <p className="text-sm text-gray-600 text-justify">Comprehensive charts and tests for accurate patient evaluation</p>
                  </div>

                  <div className="text-center p-6 bg-white/50 backdrop-blur-sm rounded-2xl border border-gray-200 hover:border-green-300 transition-colors duration-300">
                    <div className="inline-flex items-center justify-center w-14 h-14 bg-gradient-to-br from-green-500 to-emerald-500 rounded-2xl mb-4 shadow-lg">
                      <span className="text-2xl">🔬</span>
                    </div>
                    <h3 className="font-bold text-gray-900 mb-2 text-center">Diagnostic Tools</h3>
                    <p className="text-sm text-gray-600 text-justify">Advanced instruments for precise clinical examination</p>
                  </div>

                  <div className="text-center p-6 bg-white/50 backdrop-blur-sm rounded-2xl border border-gray-200 hover:border-orange-300 transition-colors duration-300">
                    <div className="inline-flex items-center justify-center w-14 h-14 bg-gradient-to-br from-orange-500 to-red-500 rounded-2xl mb-4 shadow-lg">
                      <span className="text-2xl">🤖</span>
                    </div>
                    <h3 className="font-bold text-gray-900 mb-2 text-center">AI-Powered</h3>
                    <p className="text-sm text-gray-600 text-justify">Intelligent insights for enhanced decision-making</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Image Lightbox Modal */}
          {selectedImage && (
            <div
              className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/90 backdrop-blur-md animate-fadeIn"
              onClick={() => setSelectedImage(null)}
            >
              <button
                onClick={() => setSelectedImage(null)}
                className="absolute top-4 right-4 text-white hover:text-gray-300 transition-colors z-10"
              >
                <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
              <div className="relative max-w-4xl w-full" onClick={(e) => e.stopPropagation()}>
                <img
                  src={selectedImage}
                  alt="App Screenshot"
                  className="w-full h-auto rounded-2xl shadow-2xl"
                />
              </div>
            </div>
          )}

          {/* Purpose Section */}
          <section className="relative bg-gradient-to-br from-white via-indigo-50 to-blue-50 py-16 sm:py-24 overflow-hidden">
            {/* Decorative elements */}
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
              <div className="absolute top-20 right-10 w-72 h-72 bg-blue-400 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse"></div>
              <div className="absolute bottom-20 left-10 w-72 h-72 bg-indigo-400 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-pulse" style={{animationDelay: '1s'}}></div>
              <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-purple-300 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
            </div>

            <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
              {/* Section Header */}
              <div className="text-center mb-12 sm:mb-16">
                <div className="flex flex-col sm:flex-row items-center justify-center gap-3 sm:gap-4 mb-6">
                  <div className="hidden sm:flex w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl items-center justify-center shadow-lg animate-pulse">
                    <svg className="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                  </div>
                  <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-gray-900 via-blue-800 to-indigo-900 bg-clip-text text-transparent">
                    Our Mission
                  </h2>
                  <div className="hidden sm:flex w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-2xl items-center justify-center shadow-lg animate-pulse" style={{animationDelay: '0.5s'}}>
                    <svg className="w-6 h-6 sm:w-7 sm:h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
                <div className="w-24 h-1 bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-500 rounded-full mx-auto"></div>
              </div>

              {/* Mission Cards */}
              <div className="grid md:grid-cols-2 gap-6 sm:gap-8 mb-12">
                {/* Card 1 - Empowering Professionals */}
                <div className="group relative bg-white/80 backdrop-blur-md rounded-3xl p-6 sm:p-8 shadow-xl hover:shadow-2xl transition-all duration-500 border border-blue-100 hover:border-blue-300 hover:-translate-y-2">
                  <div className="absolute -top-4 -right-4 w-20 h-20 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-2xl opacity-10 group-hover:opacity-20 transition-opacity blur-xl"></div>

                  <div className="flex items-start gap-4 mb-4">
                    <div className="flex-shrink-0 w-14 h-14 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300">
                      <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                    </div>
                    <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mt-2">Empowering Professionals</h3>
                  </div>

                  <p className="text-base sm:text-lg text-gray-700 leading-relaxed">
                    OcuHub is dedicated to empowering eye care professionals with <span className="font-semibold text-blue-700">cutting-edge digital tools</span> that streamline their workflow, improve diagnostic accuracy, and enhance patient outcomes. Our platform serves as a comprehensive ecosystem that brings together the latest advances in <span className="font-semibold text-indigo-700">ophthalmology technology and artificial intelligence</span>.
                  </p>

                  <div className="mt-6 flex flex-wrap gap-2">
                    <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-medium">Workflow Optimization</span>
                    <span className="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm font-medium">AI-Powered</span>
                    <span className="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-sm font-medium">Diagnostic Accuracy</span>
                  </div>
                </div>

                {/* Card 2 - Exceptional Care */}
                <div className="group relative bg-white/80 backdrop-blur-md rounded-3xl p-6 sm:p-8 shadow-xl hover:shadow-2xl transition-all duration-500 border border-indigo-100 hover:border-indigo-300 hover:-translate-y-2">
                  <div className="absolute -top-4 -right-4 w-20 h-20 bg-gradient-to-br from-indigo-400 to-purple-500 rounded-2xl opacity-10 group-hover:opacity-20 transition-opacity blur-xl"></div>

                  <div className="flex items-start gap-4 mb-4">
                    <div className="flex-shrink-0 w-14 h-14 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-2xl flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300">
                      <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                      </svg>
                    </div>
                    <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mt-2">Exceptional Patient Care</h3>
                  </div>

                  <p className="text-base sm:text-lg text-gray-700 leading-relaxed">
                    Whether you're a practicing <span className="font-semibold text-indigo-700">ophthalmologist</span>, <span className="font-semibold text-purple-700">optometrist</span>, or eye care professional, OcuHub provides the tools you need to deliver <span className="font-semibold text-pink-700">exceptional patient care</span> in today's digital healthcare environment.
                  </p>

                  <div className="mt-6 flex flex-wrap gap-2">
                    <span className="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm font-medium">For All Professionals</span>
                    <span className="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-sm font-medium">Digital Healthcare</span>
                    <span className="px-3 py-1 bg-pink-100 text-pink-700 rounded-full text-sm font-medium">Patient-Centered</span>
                  </div>
                </div>
              </div>

              {/* Key Stats */}
              <div className="grid grid-cols-2 gap-4 sm:gap-6 max-w-2xl mx-auto">
                <div className="text-center bg-white/60 backdrop-blur-sm rounded-2xl p-4 sm:p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
                  <div className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent mb-2">40+</div>
                  <div className="text-xs sm:text-sm text-gray-600 font-medium">Evidence-Based Tools</div>
                </div>
                <div className="text-center bg-white/60 backdrop-blur-sm rounded-2xl p-4 sm:p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
                  <div className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent mb-2">AI</div>
                  <div className="text-xs sm:text-sm text-gray-600 font-medium">Decision Assist</div>
                </div>
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
              <p className="text-base sm:text-lg mb-6 font-medium text-center">&copy; {new Date().getFullYear()} OcuHub Technologies LLC. All rights reserved.</p>

              <div className="flex flex-wrap justify-center gap-4 sm:gap-6 mb-6 sm:mb-8">
                <Link href="/privacy-policy" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Privacy Policy</Link>
                <Link href="/terms-of-service" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Terms of Service</Link>
                <Link href="/help-faq" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Help & FAQ</Link>
                <Link href="/data-deletion" className="text-blue-300 hover:text-blue-100 transition-colors underline text-sm sm:text-base font-medium">Data Deletion</Link>
              </div>

              <div className="max-w-md mx-auto text-sm sm:text-base text-gray-300 space-y-2 bg-gray-800/50 backdrop-blur-sm rounded-xl p-4 sm:p-6">
                <p className="text-center">Contact: <a href="mailto:admin@ocuhub.com" className="text-blue-300 hover:text-blue-100 transition-colors font-medium">admin@ocuhub.com</a></p>
                <p className="font-medium text-center">OcuHub Technologies LLC</p>
                <p className="text-center">Delaware, United States</p>
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
