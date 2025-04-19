// File: pages/terms-of-service.tsx

import Head from 'next/head';

export default function TermsOfService() {
  return (
    <>
      <Head>
        <title>Terms of Service | OcuHub</title>
      </Head>
      <main className="max-w-4xl mx-auto py-16 px-6 text-gray-800 dark:text-white">
        <h1 className="text-3xl font-bold mb-8">Terms of Service</h1>

        <p className="mb-6">
          Welcome to OcuHub! By using our application, website, and services, you agree to be bound by the following terms and conditions. Please read them carefully.
        </p>

        <h2 className="text-2xl font-semibold mb-4">1. Acceptance of Terms</h2>
        <p className="mb-6">
          By accessing or using OcuHub, you confirm that you are a medical professional or authorized personnel and agree to comply with these terms. If you do not agree, please do not use the service.
        </p>

        <h2 className="text-2xl font-semibold mb-4">2. Medical Disclaimer</h2>
        <p className="mb-6">
          OcuHub is a professional tool designed to support clinical decision-making. It does not replace a physician’s judgment or substitute for a professional diagnosis or treatment. You remain fully responsible for all decisions made using the tool.
        </p>

        <h2 className="text-2xl font-semibold mb-4">3. User Conduct</h2>
        <p className="mb-6">
          You agree not to misuse OcuHub, including attempting to access restricted areas, reverse engineering the software, or uploading any harmful content.
        </p>

        <h2 className="text-2xl font-semibold mb-4">4. Intellectual Property</h2>
        <p className="mb-6">
          All content, tools, logos, and trademarks in OcuHub are owned by OcuHub Technologies LLC. You may not reproduce or distribute any part of the app without our prior written consent.
        </p>

        <h2 className="text-2xl font-semibold mb-4">5. Limitation of Liability</h2>
        <p className="mb-6">
          OcuHub is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the app.
        </p>

        <h2 className="text-2xl font-semibold mb-4">6. Changes to Terms</h2>
        <p className="mb-6">
          We may update these terms from time to time. Your continued use of OcuHub after changes have been made constitutes acceptance of those changes.
        </p>

        <h2 className="text-2xl font-semibold mb-4">7. Contact Us</h2>
        <p className="mb-6">
          If you have any questions about these Terms of Service, please contact us at <a className="underline" href="mailto:admin@ocuhub.com">admin@ocuhub.com</a>.
        </p>
      </main>
    </>
  );
}