import Head from 'next/head';
import Link from 'next/link';

export default function DataDeletion() {
  return (
    <>
      <Head>
        <title>Data Deletion Request – OcuHub</title>
        <meta name="robots" content="noindex" />
      </Head>
      <main className="min-h-screen bg-white dark:bg-gray-900 text-gray-800 dark:text-white px-6 py-16 max-w-3xl mx-auto">
        <h1 className="text-4xl font-bold mb-3 text-center">Request Data Deletion</h1>
        <p className="text-center text-gray-600 dark:text-gray-300 mb-8">OcuHub Technologies LLC</p>

        <p className="mb-6">
          OcuHub provides <strong>core medical tools and calculators</strong> without requiring an account. The details below explain what data can be removed and how to request deletion based on your relationship with OcuHub.
        </p>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Account Types and Data Deletion</h2>
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-semibold mb-2">Guest Users</h3>
              <p className="mb-2">Guest users can request deletion of any information they may have shared with us through:</p>
              <ul className="list-disc list-inside space-y-1">
                <li>Support communications</li>
                <li>App improvement reports</li>
                <li>General usage patterns linked to your device</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Registered Users</h3>
              <p className="mb-2">Users with accounts (email/password or Google Sign-In) have access to additional features and can request deletion of:</p>
              <ul className="list-disc list-inside space-y-1">
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

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">How to Request Deletion</h2>
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-semibold mb-2">For All Users</h3>
              <p className="mb-2">
                Email <a className="underline" href="mailto:admin@ocuhub.com?subject=OcuHub%20Data%20Deletion%20Request">admin@ocuhub.com</a> with the subject "OcuHub Data Deletion Request" and include:
              </p>
              <ul className="list-disc list-inside space-y-1">
                <li>Your email address (if you have an account)</li>
                <li>Device information (if guest user — we'll provide simple instructions)</li>
                <li>Description of information you want deleted</li>
                <li>Your location/region (e.g., Europe, California) for proper legal compliance</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">In-App Account Deletion (Coming Soon)</h3>
              <p>
                Registered users will soon be able to delete their accounts directly from <strong>Settings → Account → Delete Account</strong>.
              </p>
            </div>
          </div>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">What We Delete</h2>
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-semibold mb-2">Information Stored on Your Device</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>All user profiles and settings stored locally</li>
                <li>Tool usage history and preferences</li>
                <li><strong>Saved favorites and bookmarks (registered users only)</strong></li>
                <li>Temporarily stored app data</li>
                <li>Session information</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Information Stored in the Cloud (For Registered Users Only)</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>User profile information backed up to our secure servers</li>
                <li>Cross-device settings and preferences</li>
                <li><strong>Synced favorites and bookmarks</strong></li>
                <li><strong>Feedback and ratings you've submitted</strong></li>
                <li>Usage patterns linked to your account</li>
                <li>Tool customizations and preferences</li>
                <li>All information synced through our secure backend</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Support and Communication Records</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Email conversations with our support team</li>
                <li>Files and attachments you've shared with us</li>
                <li>Support requests and related information</li>
              </ul>
            </div>
          </div>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Important Notes</h2>
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-semibold mb-2">Guest Users</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>You can use <strong>all core medical tools and calculators</strong> without any account</li>
                <li><strong>Favorites, syncing, and feedback features require registration</strong></li>
                <li>Local information remains on your device until you uninstall the app</li>
                <li>No personal information is collected without your explicit permission</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Registered User Benefits</h3>
              <ul className="list-disc list-inside space-y-1">
                <li><strong>Cross-device synchronization</strong> of settings and preferences</li>
                <li><strong>Save and organize favorite tools</strong></li>
                <li><strong>Submit feedback</strong> to help improve the app</li>
                <li><strong>Personalized experience</strong> with custom settings</li>
                <li><strong>Data backup</strong> for peace of mind</li>
              </ul>
            </div>
            <div>
              <h3 className="text-xl font-semibold mb-2">Account Recreation</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>You can create a new account anytime after deletion</li>
                <li>Previous information will not be restored</li>
                <li>New account starts fresh with default settings</li>
                <li><strong>You'll need to re-add favorites and preferences</strong></li>
              </ul>
            </div>
          </div>
        </section>

        <p className="mb-8">
          For more information about how we handle data, please see our{' '}
          <Link className="underline" href="/privacy-policy">Privacy Policy</Link>.
        </p>

        <p className="text-sm text-gray-500 dark:text-gray-400">Last updated: {new Date().toLocaleDateString()}</p>
      </main>
    </>
  );
}
