// File: pages/privacy.tsx
import Head from 'next/head';

export default function PrivacyPolicy() {
  return (
    <>
      <Head>
        <title>Privacy Policy - OcuHub</title>
      </Head>
      <main className="min-h-screen px-6 py-12 max-w-3xl mx-auto text-gray-800 dark:text-white">
        <h1 className="text-3xl font-bold mb-6">Privacy Policy</h1>

        <p className="mb-4">
          OcuHub is committed to protecting your personal data. This Privacy Policy explains what information we collect, how we use it, and your rights.
        </p>

        <h2 className="text-2xl font-semibold mt-6 mb-2">Information We Collect</h2>
        <ul className="list-disc ml-6 mb-4">
          <li>Email address and password when you sign up</li>
          <li>Tool usage data to improve your experience</li>
          <li>Anonymous analytics data</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-6 mb-2">How We Use Your Data</h2>
        <p className="mb-4">
          We use your information to:
        </p>
        <ul className="list-disc ml-6 mb-4">
          <li>Authenticate users</li>
          <li>Improve our services and features</li>
          <li>Provide support if needed</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-6 mb-2">Data Security</h2>
        <p className="mb-4">
          Your data is securely stored and encrypted. We do not share your personal information with third parties.
        </p>

        <h2 className="text-2xl font-semibold mt-6 mb-2">Contact</h2>
        <p>If you have questions about this policy, please email us at <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>.</p>
      </main>
    </>
  );
}
