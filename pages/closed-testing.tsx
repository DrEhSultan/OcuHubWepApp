import Head from 'next/head';
import { useState, type FormEvent } from 'react';

type Platform = 'android' | 'ios';

const initialForm = {
  fullName: '',
  email: '',
  country: '',
  platform: 'android' as Platform,
  referralCode: '',
  note: '',
};

const ClosedTestingPage = () => {
  const [form, setForm] = useState(initialForm);
  const [submitting, setSubmitting] = useState(false);
  const [successData, setSuccessData] = useState<{ code: string; email: string; referrerName?: string | null; referrerCountry?: string | null } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessData(null);

    if (!form.fullName.trim() || !form.email.trim() || !form.country.trim() || !form.referralCode.trim()) {
      setError('Please fill in all required fields.');
      return;
    }

    if (!form.email.includes('@')) {
      setError('Enter a valid email address.');
      return;
    }

    setSubmitting(true);
    try {
      const response = await fetch('/api/closed-testing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fullName: form.fullName.trim(),
          email: form.email.trim(),
          country: form.country.trim(),
          platform: form.platform,
          referralCode: form.referralCode.trim().toUpperCase(),
          note: form.note.trim(),
        }),
      });

      const payload = await response.json().catch(() => ({}));

      if (!response.ok) {
        setError(payload.error || 'Could not save your request. Please try again.');
        return;
      }

      const nextCode = form.referralCode.trim().toUpperCase();
      const nextEmail = form.email.trim();
      setSuccessData({
        code: nextCode,
        email: nextEmail,
        referrerName: payload?.referral?.name ?? null,
        referrerCountry: payload?.referral?.country ?? null,
      });
      setForm(initialForm);
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <Head>
        <title>OcuHub Closed Testing</title>
        <meta name="robots" content="noindex, nofollow" />
        <meta name="description" content="Apply to join the OcuHub closed testing group. Android builds are ready now; iOS coming soon." />
      </Head>

      <div className="min-h-screen bg-gradient-to-br from-white via-sky-50 to-indigo-50 text-slate-900 flex flex-col">
        <div className="absolute inset-0 pointer-events-none">
          <div className="absolute -top-32 -left-32 h-64 w-64 bg-indigo-200/40 rounded-full blur-3xl" aria-hidden />
          <div className="absolute -bottom-40 right-10 h-72 w-72 bg-blue-200/40 rounded-full blur-3xl" aria-hidden />
        </div>
        <main className="relative flex-1">
          <div className="max-w-6xl mx-auto px-4 py-12 sm:py-16 lg:py-20">
            <div className="grid lg:grid-cols-2 gap-10 items-start">
              <section className="space-y-5">
                <div className="flex items-center gap-3">
                  <img src="/logo.svg" alt="OcuHub logo" className="w-12 h-12 rounded-xl shadow" />
                  <div className="space-y-1">
                    <p className="text-xs font-semibold tracking-[0.25em] text-indigo-600 uppercase">Closed testing</p>
                    <p className="text-sm text-slate-500">Invite-only early access</p>
                  </div>
                </div>
                <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold leading-tight text-slate-900">
                  OcuHub Early Access
                </h1>
                <p className="text-base sm:text-lg text-slate-600 max-w-2xl">
                  Join the small group trying new features first. Android is ready now; iOS testers will be notified as soon as it ships.
                </p>
                <div className="grid sm:grid-cols-3 gap-3">
                  {[
                    { title: 'Early access', text: 'Preview features before public release.' },
                    { title: 'Direct impact', text: 'Your feedback feeds our roadmap.' },
                    { title: 'Priority support', text: 'We’ll follow up and close the loop.' },
                  ].map((item) => (
                    <div key={item.title} className="rounded-2xl border border-indigo-100 bg-white/80 p-4 shadow-sm backdrop-blur">
                      <p className="text-sm font-semibold text-indigo-700">{item.title}</p>
                      <p className="text-xs text-slate-600 mt-1">{item.text}</p>
                    </div>
                  ))}
                </div>
                <div className="rounded-2xl border border-slate-200 bg-white/80 p-4 shadow-sm backdrop-blur">
                  <p className="text-sm text-slate-700">
                    Keep this link private. You can also share feedback anytime inside the app (Feedback tool or Settings → Feedback).
                  </p>
                </div>
              </section>

              <section className="bg-white border border-slate-200 rounded-2xl p-6 shadow-xl shadow-indigo-100/60">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-xl font-semibold text-slate-900">Join closed testing</h2>
                    <p className="text-xs text-slate-500">Fast form • no spam</p>
                  </div>
                  <span className="text-xs text-amber-600 bg-amber-100 px-3 py-1 rounded-full">iOS coming soon</span>
                </div>
                <form className="space-y-4" onSubmit={handleSubmit}>
                  <div>
                    <label className="block text-sm text-slate-700 mb-1">Full name*</label>
                    <input
                      type="text"
                      value={form.fullName}
                      onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                      className="w-full rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="Dr. Jane Doe"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-700 mb-1">Email* (same as your Play Store / Apple ID)</label>
                    <input
                      type="email"
                      value={form.email}
                      onChange={(e) => setForm({ ...form, email: e.target.value })}
                      className="w-full rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="you@example.com"
                      required
                    />
                  </div>
                  <div className="grid sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm text-slate-700 mb-1">Country*</label>
                      <input
                        type="text"
                        value={form.country}
                        onChange={(e) => setForm({ ...form, country: e.target.value })}
                        className="w-full rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-indigo-400"
                        placeholder="United States, Canada, UAE..."
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-700 mb-1">Platform*</label>
                      <div className="flex gap-2">
                        {(['android', 'ios'] as Platform[]).map((platform) => (
                          <button
                            type="button"
                            key={platform}
                            onClick={() => setForm({ ...form, platform })}
                            className={`flex-1 rounded-xl px-3 py-2 text-sm font-semibold border transition ${
                              form.platform === platform
                                ? 'bg-indigo-500 text-white border-indigo-500 shadow'
                                : 'bg-slate-50 text-slate-700 border-slate-200 hover:border-indigo-300'
                            }`}
                          >
                            {platform === 'android' ? 'Android (ready)' : 'iOS (notify me)'}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm text-slate-700 mb-1">Referral code (uppercase)*</label>
                    <input
                      type="text"
                      value={form.referralCode}
                      onChange={(e) => setForm({ ...form, referralCode: e.target.value.toUpperCase() })}
                      className="w-full rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-slate-900 uppercase tracking-wide focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="EXAMPLECODE"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-700 mb-1">Anything we should know? (optional)</label>
                    <textarea
                      rows={3}
                      value={form.note}
                      onChange={(e) => setForm({ ...form, note: e.target.value })}
                      className="w-full rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="Device, specialty, or what you want to test most."
                    />
                  </div>

                  {error && (
                    <p className="text-sm text-rose-600 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2">
                      {error}
                    </p>
                  )}
                  {successData && (
                    <div className="text-sm text-emerald-800 bg-emerald-50 border border-emerald-200 rounded-lg px-3 py-3 space-y-1.5">
                      <p className="font-semibold">Thanks for joining the test group.</p>
                      <p>
                        Referral code <span className="font-mono font-semibold">{successData.code}</span> confirmed.
                        {successData.referrerName && (
                          <> Referred by {successData.referrerName}{successData.referrerCountry ? ` (${successData.referrerCountry})` : ''} for early access testing.</>
                        )}
                      </p>
                      <p>Please use the same email <span className="font-semibold">{successData.email}</span> as your Google Play or Apple ID so we can enable testing access.</p>
                      <p>
                        You’ll get the download link when it’s ready — you can also check{' '}
                        <a href="https://ocuhub.com" target="_blank" rel="noreferrer" className="text-indigo-700 underline font-semibold">
                          OcuHub.com
                        </a>
                        .
                      </p>
                    </div>
                  )}

                  <button
                    type="submit"
                    disabled={submitting}
                    className="w-full rounded-xl bg-indigo-600 hover:bg-indigo-700 px-4 py-3 font-semibold text-white transition disabled:opacity-60 disabled:cursor-not-allowed shadow-lg shadow-indigo-200"
                  >
                    {submitting ? 'Submitting...' : 'Join closed testing'}
                  </button>
                  <p className="text-xs text-slate-500 text-center">
                    We only email you about testing access.
                  </p>
                </form>
              </section>
            </div>
          </div>
        </main>
      </div>
    </>
  );
};

export default ClosedTestingPage;
