// File: pages/privacy-policy.tsx

import Head from 'next/head';

export default function PrivacyPolicy() {
  return (
    <>
      <Head>
        <title>Privacy Policy – OcuHub</title>
      </Head>
      <main className="min-h-screen bg-white dark:bg-gray-900 text-gray-800 dark:text-white px-6 py-16 max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold mb-2 text-center">Privacy Policy – OcuHub</h1>
        <p className="text-center text-gray-600 dark:text-gray-300 mb-8">Effective date: 21 Sep 2025</p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Who we are</h2>
        <p className="mb-4">
          OcuHub is a medical education/reference app for eye-care professionals. We do not diagnose, treat, or predict medical conditions.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Data we collect</h2>
        <ul className="list-disc list-inside mb-4 space-y-1">
          <li>Identifiers: name, email, (optional) medical specialty.</li>
          <li>Usage &amp; diagnostics: app usage metrics and crash/error logs.</li>
          <li>No health records/PHI are collected through the app.</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-8 mb-2">How we use data</h2>
        <p className="mb-4">
          Provide and improve app features, respond to support, maintain security, and send essential notices.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Sharing</h2>
        <p className="mb-4">
          We do not sell personal data. We may use processors (e.g., Google Firebase / Google Analytics) to provide analytics and infrastructure; they process data under their policies.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Retention &amp; deletion</h2>
        <p className="mb-4">
          We retain personal data until you request deletion or as required for legitimate purposes. You can request deletion at any time by emailing <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a> (subject: “OcuHub Data Deletion”). We will confirm completion within 30 days.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">International transfers</h2>
        <p className="mb-4">
          Data may be processed on servers outside your country. We apply safeguards appropriate to the data and purpose.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Permissions</h2>
        <p className="mb-4">
          The app does not request sensitive device permissions unless explicitly required for a feature; such permissions will be clearly disclosed in-app.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Audience</h2>
        <p className="mb-4">
          OcuHub targets adult professionals (ophthalmologists/optometrists/nurses/orthoptists). It is not directed to children.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Your rights</h2>
        <p className="mb-4">
          Where applicable (e.g., GDPR), you may request access, correction, deletion, or objection to certain processing by contacting <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Changes</h2>
        <p className="mb-4">
          We may update this policy; the latest version and date will always be posted at <a href="https://ocuhub.com/privacy-policy" className="underline" target="_blank" rel="noopener noreferrer">https://ocuhub.com/privacy-policy</a>.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Contact</h2>
        <p className="mb-4">
          <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>
        </p>
      </main>
    </>
  );
}
