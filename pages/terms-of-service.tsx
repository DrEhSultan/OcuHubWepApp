// File: pages/terms-of-service.tsx

import Head from 'next/head';

export default function TermsOfService() {
  return (
    <>
      <Head>
        <title>Terms of Service | OcuHub</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-blue-900 dark:to-indigo-900 px-4 sm:px-6 lg:px-8 py-12 sm:py-20">
        <div className="max-w-4xl mx-auto bg-white/80 dark:bg-gray-800/80 backdrop-blur-md rounded-2xl shadow-soft p-6 sm:p-10 lg:p-12">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-8 sm:mb-12 text-center bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Terms of Service</h1>

          <div className="space-y-8 sm:space-y-10 text-gray-800 dark:text-white">
            <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
              Welcome to OcuHub! By using our application, website, and services, you agree to be bound by the following terms and conditions. Please read them carefully.
            </p>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">1. Acceptance of Terms</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                By accessing or using OcuHub, you confirm that you are a medical professional or authorized personnel and agree to comply with these terms. If you do not agree, please do not use the service.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">2. Medical Disclaimer</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                OcuHub is a professional tool designed to support clinical decision-making. It does not replace a physician's judgment or substitute for a professional diagnosis or treatment. You remain fully responsible for all decisions made using the tool.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">3. User Conduct</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                You agree not to misuse OcuHub, including attempting to access restricted areas, reverse engineering the software, or uploading any harmful content.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">4. Intellectual Property</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                All content, tools, logos, and trademarks in OcuHub are owned by OcuHub Technologies LLC. You may not reproduce or distribute any part of the app without our prior written consent.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">5. Limitation of Liability</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                OcuHub is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the app.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">6. Changes to Terms</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                We may update these terms from time to time. Your continued use of OcuHub after changes have been made constitutes acceptance of those changes.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">7. Contact Us</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                If you have any questions about these Terms of Service, please contact us at <a className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors" href="mailto:admin@ocuhub.com">admin@ocuhub.com</a>.
              </p>
            </section>
          </div>
        </div>
      </main>
    </>
  );
}