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
              These Terms govern your use of OcuHub, including our app, website, and services. OcuHub is a global ophthalmology platform built for healthcare professionals and authorized personnel. By accessing or using OcuHub, you agree to these Terms.
            </p>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">1. Acceptance of Terms</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                OcuHub is intended only for licensed clinicians, clinical trainees, or authorized healthcare staff acting within their professional roles. By using OcuHub, you confirm you meet these requirements, will follow applicable laws and institutional policies, and accept these Terms. If you do not agree or are not authorized, do not use OcuHub.
              </p>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">2. Medical Disclaimer</h2>
              <div className="space-y-3 text-sm sm:text-base lg:text-lg leading-relaxed">
                <p>
                  OcuHub is provided for educational and clinical reference only. It is not a medical device, and it is not intended to diagnose, treat, cure, or prevent any disease or condition. It is not a substitute for professional judgment, experience, or consultation. You remain solely responsible for all clinical decisions, patient care, and compliance with local regulations. OcuHub does not create a clinician-patient relationship and does not provide patient-specific medical advice.
                </p>
                <ul className="list-disc list-inside space-y-2">
                  <li>Educational and clinical reference only.</li>
                  <li>Not a medical device.</li>
                  <li>Not intended to diagnose, treat, cure, or prevent disease.</li>
                  <li>Not a substitute for professional judgment or supervision.</li>
                  <li>You are responsible for all clinical decisions and outcomes.</li>
                </ul>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">3. User Conduct</h2>
              <div className="space-y-3 text-sm sm:text-base lg:text-lg leading-relaxed">
                <p>
                  Use OcuHub responsibly and only as permitted by law and your organization. Do not upload protected health information unless allowed by your policies and applicable privacy laws. Do not misuse, interfere with, or disrupt the service; attempt unauthorized access; introduce malware; or use OcuHub to develop competing products. You are responsible for the security of your account and any activity under it.
                </p>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">4. Intellectual Property</h2>
              <div className="space-y-3 text-sm sm:text-base lg:text-lg leading-relaxed">
                <p>
                  OcuHub, including its content, software, design, and trademarks, is owned by OcuHub Technologies LLC or its licensors. We grant you a limited, revocable, non-transferable license to use OcuHub for your authorized professional work. You may not copy, modify, distribute, resell, or create derivative works from OcuHub without our written permission.
                </p>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">5. Limitation of Liability</h2>
              <div className="space-y-3 text-sm sm:text-base lg:text-lg leading-relaxed">
                <p>
                  OcuHub is provided on an “as is” and “as available” basis. To the fullest extent permitted by law, we disclaim all warranties, express or implied, including fitness for a particular purpose and non-infringement. We are not liable for any loss, injury, or damages arising from your use of OcuHub, including any decisions you make or fail to make while using the service.
                </p>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">6. Changes to Terms</h2>
              <div className="space-y-3 text-sm sm:text-base lg:text-lg leading-relaxed">
                <p>
                  We may update these Terms to reflect changes in our service, legal requirements, or best practices. Updated Terms will be posted with a revised effective date. Your continued use after the updates take effect means you accept the revised Terms.
                </p>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-3 sm:mb-4 text-blue-600 dark:text-blue-400">7. Contact Us</h2>
              <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
                If you have questions about these Terms or how we operate OcuHub, contact us at <a className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors" href="mailto:admin@ocuhub.com">admin@ocuhub.com</a>.
              </p>
            </section>
          </div>
        </div>
      </main>
    </>
  );
}
