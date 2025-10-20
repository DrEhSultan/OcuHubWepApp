import React from 'react';
import Head from 'next/head';

const faqs = [
  {
    question: 'What is OcuHub?',
    answer: 'OcuHub is a comprehensive digital platform designed specifically for ophthalmologists, optometrists, and eye care professionals. Our platform provides essential tools and resources to enhance clinical decision-making and improve patient care.'
  }
];

export default function HelpFaq() {
  return (
    <>
      <Head>
        <title>Help & FAQ – OcuHub</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 py-12 sm:py-16 lg:py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-center mb-8 sm:mb-12 bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Help & FAQ</h1>

          <section className="mb-10 sm:mb-16 bg-white/80 backdrop-blur-md rounded-2xl shadow-soft p-6 sm:p-8 lg:p-10 border border-gray-100">
            <h2 className="text-2xl sm:text-3xl font-bold mb-4 sm:mb-6 text-blue-600">General Help</h2>
            <div className="space-y-4 text-gray-700">
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                Welcome to OcuHub! If you have any questions or need assistance, you can find answers below or reach out to our support team.
              </p>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                For urgent issues, please email <a href="mailto:admin@OcuHub.com" className="text-blue-600 hover:text-blue-800 underline font-medium transition-colors">admin@OcuHub.com</a>.
              </p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl sm:text-3xl font-bold mb-6 sm:mb-8 text-center text-gray-900">Frequently Asked Questions</h2>
            <div className="space-y-6 sm:space-y-8">
              {faqs.map((faq, idx) => (
                <div key={idx} className="group bg-white/80 backdrop-blur-md p-6 sm:p-8 lg:p-10 rounded-2xl shadow-soft hover:shadow-glow transition-all duration-300 hover:-translate-y-1 border border-gray-100">
                  <h3 className="text-lg sm:text-xl lg:text-2xl font-bold text-blue-600 mb-3 sm:mb-4 group-hover:text-blue-700 transition-colors">{faq.question}</h3>
                  <p className="text-sm sm:text-base lg:text-lg text-gray-700 leading-relaxed">{faq.answer}</p>
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
    </>
  );
} 