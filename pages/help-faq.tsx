import React from 'react';

const faqs = [
  {
    question: 'What is OcuHub?',
    answer: 'OcuHub is a platform designed to help users manage and access their resources efficiently.'
  },
  {
    question: 'How do I create an account?',
    answer: 'Click on the Sign Up button on the homepage and fill in the required information.'
  },
  {
    question: 'Is my data secure?',
    answer: 'Yes, we use industry-standard security measures to protect your data.'
  },
  {
    question: 'How can I contact support?',
    answer: 'You can contact support by emailing support@ocuhub.com.'
  },
  // Add more FAQs as needed
];

export default function HelpFaq() {
  return (
    <div className="min-h-screen bg-gray-50 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-900">Help & FAQ</h1>
        <section className="mb-12">
          <h2 className="text-2xl font-semibold mb-4 text-gray-800">General Help</h2>
          <p className="text-gray-700 mb-2">
            Welcome to OcuHub! If you have any questions or need assistance, you can find answers below or reach out to our support team.
          </p>
          <p className="text-gray-700">
            For urgent issues, please email <a href="mailto:support@ocuhub.com" className="text-blue-600 underline">support@ocuhub.com</a>.
          </p>
        </section>
        <section>
          <h2 className="text-2xl font-semibold mb-4 text-gray-800">Frequently Asked Questions</h2>
          <div className="space-y-6">
            {faqs.map((faq, idx) => (
              <div key={idx} className="bg-white p-6 rounded-lg shadow">
                <h3 className="text-lg font-medium text-gray-900 mb-2">{faq.question}</h3>
                <p className="text-gray-700">{faq.answer}</p>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
} 