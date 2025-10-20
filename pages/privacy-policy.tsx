// File: pages/privacy-policy.tsx

import Head from 'next/head';

export default function PrivacyPolicy() {
  return (
    <>
      <Head>
        <title>Privacy Policy – OcuHub</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-blue-900 dark:to-indigo-900 px-4 sm:px-6 lg:px-8 py-12 sm:py-20">
        <div className="max-w-4xl mx-auto bg-white/80 dark:bg-gray-800/80 backdrop-blur-md rounded-2xl shadow-soft p-6 sm:p-10 lg:p-12">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-3 text-center bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Privacy Policy – OcuHub</h1>
          <p className="text-center text-sm sm:text-base text-gray-600 dark:text-gray-300 mb-10 sm:mb-12 font-medium">Effective date: 21 Sep 2025</p>

          <div className="space-y-8 sm:space-y-10 text-gray-800 dark:text-white">
            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Who we are</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                OcuHub is a medical education/reference app for eye-care professionals. We do not diagnose, treat, or predict medical conditions.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Data we collect</h2>
              <ul className="list-disc list-inside space-y-2 text-sm sm:text-base lg:text-lg leading-relaxed ml-2 sm:ml-4">
                <li>Identifiers: name, email, (optional) medical specialty.</li>
                <li>Usage &amp; diagnostics: app usage metrics and crash/error logs.</li>
                <li>No health records/PHI are collected through the app.</li>
              </ul>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">How we use data</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                Provide and improve app features, respond to support, maintain security, and send essential notices.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Sharing</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                We do not sell personal data. We may use processors (e.g., Google Firebase / Google Analytics) to provide analytics and infrastructure; they process data under their policies.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Retention &amp; deletion</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                We retain personal data until you request deletion or as required for legitimate purposes. You can request deletion at any time by emailing <a href="mailto:admin@ocuhub.com" className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors">admin@ocuhub.com</a> (subject: "OcuHub Data Deletion"). We will confirm completion within 30 days.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">International transfers</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                Data may be processed on servers outside your country. We apply safeguards appropriate to the data and purpose.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Permissions</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                The app does not request sensitive device permissions unless explicitly required for a feature; such permissions will be clearly disclosed in-app.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Audience</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                OcuHub targets adult professionals (ophthalmologists/optometrists/nurses/orthoptists). It is not directed to children.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Your rights</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                Where applicable (e.g., GDPR), you may request access, correction, deletion, or objection to certain processing by contacting <a href="mailto:admin@ocuhub.com" className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors">admin@ocuhub.com</a>.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Changes</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                We may update this policy; the latest version and date will always be posted at <a href="https://ocuhub.com/privacy-policy" className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors" target="_blank" rel="noopener noreferrer">https://ocuhub.com/privacy-policy</a>.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">Contact</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                <a href="mailto:admin@ocuhub.com" className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors">admin@ocuhub.com</a>
              </p>
            </section>
          </div>
        </div>
      </main>
    </>
  );
}
