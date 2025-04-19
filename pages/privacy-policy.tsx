// File: pages/privacy-policy.tsx

import Head from 'next/head';

export default function PrivacyPolicy() {
  return (
    <>
      <Head>
        <title>Privacy Policy | OcuHub</title>
      </Head>
      <main className="min-h-screen bg-white dark:bg-gray-900 text-gray-800 dark:text-white px-6 py-16 max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold mb-6 text-center">Privacy Policy</h1>

        <p className="mb-4">
          At OcuHub, we are committed to protecting your privacy and ensuring that your personal information is handled in a safe and responsible manner. This Privacy Policy outlines how we collect, use, and safeguard your data.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">1. Information We Collect</h2>
        <p className="mb-4">
          We may collect personal information such as your name, email address, medical specialization, and usage activity to personalize your experience and enhance the functionality of our services.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">2. How We Use Your Information</h2>
        <p className="mb-4">
          Your information is used to:
        </p>
        <ul className="list-disc list-inside mb-4">
          <li>Provide and improve our services</li>
          <li>Analyze usage patterns to optimize user experience</li>
          <li>Respond to user inquiries and feedback</li>
          <li>Send important updates and notifications</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-8 mb-2">3. Data Protection</h2>
        <p className="mb-4">
          We implement appropriate technical and organizational measures to protect your data from unauthorized access, alteration, or disclosure.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">4. Third-Party Services</h2>
        <p className="mb-4">
          We may integrate with third-party services (e.g. Firebase, Google Analytics) which may collect information in accordance with their own privacy policies. We encourage you to review their terms.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">5. Your Choices</h2>
        <p className="mb-4">
          You have the right to access, update, or delete your personal information. You may also choose to opt out of certain communications.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">6. Changes to This Policy</h2>
        <p className="mb-4">
          We may update this policy from time to time. All changes will be posted on this page with an updated revision date.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">7. Contact Us</h2>
        <p className="mb-4">
          If you have any questions or concerns about this policy, please contact us at <a href="mailto:admin@ocuhub.com" className="underline">admin@ocuhub.com</a>.
        </p>
      </main>
    </>
  );
}