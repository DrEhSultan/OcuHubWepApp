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

        <p className="mb-4">
          OcuHub does not require users to create an account. If you have shared personal data with us (for example, via support email) and would like to request deletion of some or all of that data, please follow the steps below.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-2">How to request deletion</h2>
        <ol className="list-decimal list-inside space-y-2 mb-4">
          <li>
            Email <a className="underline" href="mailto:admin@ocuhub.com?subject=OcuHub%20Data%20Deletion%20Request">admin@ocuhub.com</a> with the subject “OcuHub Data Deletion Request”.
          </li>
          <li>
            Include the email address you used to contact us (or any identifier you provided) and describe the data you want deleted.
          </li>
          <li>
            If applicable, mention your jurisdiction (e.g., GDPR, CCPA) so we can apply the correct process.
          </li>
        </ol>

        <h2 className="text-2xl font-semibold mt-8 mb-2">What we delete</h2>
        <ul className="list-disc list-inside space-y-2 mb-4">
          <li>Personal identifiers you provided directly (e.g., name, email, specialty).</li>
          <li>Support communications and attachments you sent to us.</li>
          <li>Any logs that are reasonably linkable to your request and not required to maintain security or comply with law.</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-8 mb-2">What may be retained</h2>
        <ul className="list-disc list-inside space-y-2 mb-4">
          <li>Data we must keep to comply with legal, tax, or regulatory obligations.</li>
          <li>Security, fraud-prevention, or abuse-detection records where retention is necessary.</li>
          <li>Aggregated or de-identified analytics that are not reasonably linkable to you.</li>
          <li>Data in system backups for a limited time until they cycle out per our retention schedule.</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-8 mb-2">Timeframe and security</h2>
        <ul className="list-disc list-inside space-y-2 mb-8">
          <li>We aim to complete verified deletion requests as promptly as possible and confirm within 30 days.</li>
          <li>All communications and transfers are encrypted in transit via HTTPS/TLS.</li>
        </ul>

        <p className="mb-8">
          For more information about how we handle data, please see our{' '}
          <Link className="underline" href="/privacy-policy">Privacy Policy</Link>.
        </p>

        <p className="text-sm text-gray-500 dark:text-gray-400">Last updated: {new Date().toLocaleDateString()}</p>
      </main>
    </>
  );
}

