import Head from 'next/head';
import Link from 'next/link';
import { formatShortDate } from '../lib/dateUtils';

export default function DataDeletion() {
  return (
    <>
      <Head>
        <title>Data Deletion Request – OcuHub</title>
        <meta name="robots" content="noindex" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      <main className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 dark:from-gray-900 dark:via-blue-900 dark:to-indigo-900 px-4 sm:px-6 lg:px-8 py-12 sm:py-20">
        <div className="max-w-4xl mx-auto bg-white/80 dark:bg-gray-800/80 backdrop-blur-md rounded-2xl shadow-soft p-6 sm:p-10 lg:p-12">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-3 text-center bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Request Data Deletion</h1>
          <p className="text-center text-sm sm:text-base text-gray-600 dark:text-gray-300 mb-8 sm:mb-12 font-medium">OcuHub Technologies LLC</p>

          <div className="space-y-8 sm:space-y-10 text-gray-800 dark:text-white">
            <p className="text-sm sm:text-base lg:text-lg leading-relaxed">
              OcuHub provides <strong>core medical tools and calculators</strong> without requiring an account. The details below explain what data can be removed and how to request deletion based on your relationship with OcuHub.
            </p>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-4 sm:mb-6 text-blue-600 dark:text-blue-400">Account Types and Data Deletion</h2>
              <div className="space-y-6 sm:space-y-8">
                <div className="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-4 sm:p-6 border border-blue-100 dark:border-blue-800">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Guest Users</h3>
                  <p className="mb-3 text-sm sm:text-base leading-relaxed">Guest users can request deletion of any information they may have shared with us through:</p>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>Support communications</li>
                    <li>App improvement reports</li>
                    <li>General usage patterns linked to your device</li>
                  </ul>
                </div>
                <div className="bg-indigo-50 dark:bg-indigo-900/20 rounded-xl p-4 sm:p-6 border border-indigo-100 dark:border-indigo-800">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Registered Users</h3>
                  <p className="mb-3 text-sm sm:text-base leading-relaxed">Users with accounts (email/password or Google Sign-In) have access to additional features and can request deletion of:</p>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>Account profile information (name, email, profile image)</li>
                    <li>Personalized settings and preferences</li>
                    <li><strong>Synced data across your devices</strong></li>
                    <li><strong>Saved favorites and bookmarks</strong></li>
                    <li><strong>Feedback and ratings you've submitted</strong></li>
                    <li>App usage patterns and session information</li>
                    <li>Support communications</li>
                  </ul>
                </div>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-4 sm:mb-6 text-blue-600 dark:text-blue-400">How to Request Deletion</h2>
              <div className="space-y-6 sm:space-y-8">
                <div className="bg-white dark:bg-gray-700/50 rounded-xl p-4 sm:p-6 shadow-md border border-gray-200 dark:border-gray-600">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">For All Users</h3>
                  <p className="mb-3 text-sm sm:text-base leading-relaxed">
                    Email <a className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors" href="mailto:admin@ocuhub.com?subject=OcuHub%20Data%20Deletion%20Request">admin@ocuhub.com</a> with the subject "OcuHub Data Deletion Request" and include:
                  </p>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>Your email address (if you have an account)</li>
                    <li>Device information (if guest user — we'll provide simple instructions)</li>
                    <li>Description of information you want deleted</li>
                    <li>Your location/region (e.g., Europe, California) for proper legal compliance</li>
                  </ul>
                </div>
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl p-4 sm:p-6 border border-blue-200 dark:border-blue-700">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">In-App Account Deletion (Coming Soon)</h3>
                  <p className="text-sm sm:text-base leading-relaxed">
                    Registered users will soon be able to delete their accounts directly from <strong>Settings → Account → Delete Account</strong>.
                  </p>
                </div>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-4 sm:mb-6 text-blue-600 dark:text-blue-400">What We Delete</h2>
              <div className="space-y-6 sm:space-y-8">
                <div className="bg-white dark:bg-gray-700/50 rounded-xl p-4 sm:p-6 shadow-md border border-gray-200 dark:border-gray-600">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Information Stored on Your Device</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>All user profiles and settings stored locally</li>
                    <li>Tool usage history and preferences</li>
                    <li><strong>Saved favorites and bookmarks (registered users only)</strong></li>
                    <li>Temporarily stored app data</li>
                    <li>Session information</li>
                  </ul>
                </div>
                <div className="bg-white dark:bg-gray-700/50 rounded-xl p-4 sm:p-6 shadow-md border border-gray-200 dark:border-gray-600">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Information Stored in the Cloud (For Registered Users Only)</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>User profile information backed up to our secure servers</li>
                    <li>Cross-device settings and preferences</li>
                    <li><strong>Synced favorites and bookmarks</strong></li>
                    <li><strong>Feedback and ratings you've submitted</strong></li>
                    <li>Usage patterns linked to your account</li>
                    <li>Tool customizations and preferences</li>
                    <li>All information synced through our secure backend</li>
                  </ul>
                </div>
                <div className="bg-white dark:bg-gray-700/50 rounded-xl p-4 sm:p-6 shadow-md border border-gray-200 dark:border-gray-600">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Support and Communication Records</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>Email conversations with our support team</li>
                    <li>Files and attachments you've shared with us</li>
                    <li>Support requests and related information</li>
                  </ul>
                </div>
              </div>
            </section>

            <section>
              <h2 className="text-xl sm:text-2xl lg:text-3xl font-bold mb-4 sm:mb-6 text-blue-600 dark:text-blue-400">Important Notes</h2>
              <div className="space-y-6 sm:space-y-8">
                <div className="bg-green-50 dark:bg-green-900/20 rounded-xl p-4 sm:p-6 border border-green-200 dark:border-green-700">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Guest Users</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>You can use <strong>all core medical tools and calculators</strong> without any account</li>
                    <li><strong>Favorites, syncing, and feedback features require registration</strong></li>
                    <li>Local information remains on your device until you uninstall the app</li>
                    <li>No personal information is collected without your explicit permission</li>
                  </ul>
                </div>
                <div className="bg-purple-50 dark:bg-purple-900/20 rounded-xl p-4 sm:p-6 border border-purple-200 dark:border-purple-700">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Registered User Benefits</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li><strong>Cross-device synchronization</strong> of settings and preferences</li>
                    <li><strong>Save and organize favorite tools</strong></li>
                    <li><strong>Submit feedback</strong> to help improve the app</li>
                    <li><strong>Personalized experience</strong> with custom settings</li>
                    <li><strong>Data backup</strong> for peace of mind</li>
                  </ul>
                </div>
                <div className="bg-amber-50 dark:bg-amber-900/20 rounded-xl p-4 sm:p-6 border border-amber-200 dark:border-amber-700">
                  <h3 className="text-lg sm:text-xl font-bold mb-3 text-gray-900 dark:text-white">Account Recreation</h3>
                  <ul className="list-disc list-inside space-y-2 ml-2 sm:ml-4 text-sm sm:text-base">
                    <li>You can create a new account anytime after deletion</li>
                    <li>Previous information will not be restored</li>
                    <li>New account starts fresh with default settings</li>
                    <li><strong>You'll need to re-add favorites and preferences</strong></li>
                  </ul>
                </div>
              </div>
            </section>

            <p className="text-sm sm:text-base lg:text-lg leading-relaxed bg-blue-50 dark:bg-blue-900/20 rounded-xl p-4 sm:p-6 border border-blue-200 dark:border-blue-700">
              For more information about how we handle data, please see our{' '}
              <Link className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 underline font-medium transition-colors" href="/privacy-policy">Privacy Policy</Link>.
            </p>

            <p className="text-xs sm:text-sm text-center text-gray-500 dark:text-gray-400 italic">Last updated: {formatShortDate(new Date().toISOString())}</p>
          </div>
        </div>
      </main>
    </>
  );
}
