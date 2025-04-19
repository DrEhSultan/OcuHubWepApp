// File: pages/terms.tsx

import Head from 'next/head';

export default function TermsOfService() {
  return (
    <>
      <Head>
        <title>Terms of Service | OcuHub</title>
      </Head>
      <main className="min-h-screen bg-white dark:bg-gray-900 text-gray-800 dark:text-white px-6 py-16 max-w-3xl mx-auto">
        <h1 className="text-3xl font-bold mb-6">Terms of Service</h1>

        <p className="mb-4">
          These Terms of Service ("Terms") govern your access to and use of OcuHub's mobile and web applications. By using our services, you agree to be bound by these Terms.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">1. Acceptance of Terms</h2>
        <p className="mb-4">
          By using the OcuHub platform, you confirm that you are a licensed eye care professional or affiliated user and agree to comply with all applicable laws and regulations.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">2. Use of Service</h2>
        <p className="mb-4">
          OcuHub provides ophthalmology tools, clinical calculators, and educational content. All tools are for informational and professional support purposes only and do not replace medical judgment.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">3. Accounts and Access</h2>
        <p className="mb-4">
          You are responsible for maintaining the confidentiality of your login credentials and for any activities under your account. We may suspend access for security or abuse concerns.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">4. Intellectual Property</h2>
        <p className="mb-4">
          All content, trademarks, and services provided through OcuHub are the property of OcuHub Technologies LLC. You may not copy, modify, or redistribute any part without explicit permission.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">5. Disclaimers</h2>
        <p className="mb-4">
          OcuHub does not offer medical advice. All tools and data are intended for use by professionals. Use at your own discretion. We are not liable for clinical decisions made using our tools.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">6. Changes to Terms</h2>
        <p className="mb-4">
          We may update these Terms from time to time. Continued use of the platform after changes implies acceptance of the new Terms.
        </p>

        <h2 className="text-xl font-semibold mt-6 mb-2">7. Contact</h2>
        <p>
          For questions about these Terms, contact us at{' '}
          <a href="mailto:admin@ocuhub.com" className="text-blue-600 underline">admin@ocuhub.com</a>.
        </p>
      </main>
    </>
  );
}
