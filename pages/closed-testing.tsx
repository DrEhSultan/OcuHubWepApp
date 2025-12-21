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
  const [success, setSuccess] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

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

      setSuccess('You’re on the list! We’ll email you as soon as your build is ready.');
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

      <div className="min-h-screen bg-slate-950 text-white flex flex-col">
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-900/40 via-slate-900 to-slate-950 pointer-events-none" aria-hidden />
        <main className="relative flex-1">
          <div className="max-w-6xl mx-auto px-4 py-14 sm:py-18 lg:py-24">
            <div className="grid lg:grid-cols-2 gap-10 items-start">
              <section className="space-y-4">
                <p className="inline-flex items-center gap-2 rounded-full bg-indigo-500/15 text-indigo-100 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em]">
                  Invite-only
                  <span className="text-[10px] rounded-full bg-indigo-400/30 px-2 py-0.5">Closed testing</span>
                </p>
                <h1 className="text-4xl sm:text-5xl font-bold leading-tight">
                  Help us shape the next build of <span className="text-indigo-300">OcuHub</span>
                </h1>
                <p className="text-lg text-slate-300 max-w-2xl">
                  We’re inviting a small group to try new features before public release. Android builds are ready now. iOS is still in progress—sign up and we’ll notify you the moment it’s live.
                </p>
                <div className="grid sm:grid-cols-2 gap-4 pt-4">
                  <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
                    <p className="text-sm text-slate-400 mb-1">Why join</p>
                    <p className="text-base font-semibold text-white">Early access, direct influence, priority support.</p>
                  </div>
                  <div className="rounded-2xl border border-indigo-500/30 bg-indigo-500/10 p-4">
                    <p className="text-sm text-indigo-200 mb-1">We value your time</p>
                    <p className="text-base font-semibold text-white">We’ll act on your feedback and keep you updated.</p>
                  </div>
                </div>

                <div className="rounded-2xl border border-white/5 bg-slate-900/60 p-4 space-y-2">
                  <p className="text-sm text-slate-300">
                    Prefer to share feedback later? You can also send feedback inside the app (Feedback tool, any calculator, or Settings → Feedback). Every note helps and we’ll make sure you get credit.
                  </p>
                  <p className="text-sm text-slate-400">
                    This page is not linked from the homepage—please keep the URL private.
                  </p>
                </div>
              </section>

              <section className="bg-slate-900/80 border border-white/10 rounded-2xl p-6 shadow-2xl shadow-indigo-900/20">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-xl font-semibold">Join the closed testing list</h2>
                  <span className="text-xs text-amber-200 bg-amber-500/20 px-3 py-1 rounded-full">iOS coming soon</span>
                </div>
                <form className="space-y-4" onSubmit={handleSubmit}>
                  <div>
                    <label className="block text-sm text-slate-300 mb-1">Full name*</label>
                    <input
                      type="text"
                      value={form.fullName}
                      onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                      className="w-full rounded-xl bg-slate-800 border border-white/10 px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="Dr. Jane Doe"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-300 mb-1">Email*</label>
                    <input
                      type="email"
                      value={form.email}
                      onChange={(e) => setForm({ ...form, email: e.target.value })}
                      className="w-full rounded-xl bg-slate-800 border border-white/10 px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="you@example.com"
                      required
                    />
                  </div>
                  <div className="grid sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm text-slate-300 mb-1">Country*</label>
                      <input
                        type="text"
                        value={form.country}
                        onChange={(e) => setForm({ ...form, country: e.target.value })}
                        className="w-full rounded-xl bg-slate-800 border border-white/10 px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-indigo-400"
                        placeholder="Egypt, Saudi Arabia, USA..."
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-300 mb-1">Platform*</label>
                      <div className="flex gap-2">
                        {(['android', 'ios'] as Platform[]).map((platform) => (
                          <button
                            type="button"
                            key={platform}
                            onClick={() => setForm({ ...form, platform })}
                            className={`flex-1 rounded-xl px-3 py-2 text-sm font-semibold border ${
                              form.platform === platform
                                ? 'bg-indigo-500 text-white border-indigo-400'
                                : 'bg-slate-800 text-slate-200 border-white/10 hover:border-indigo-400/50'
                            }`}
                          >
                            {platform === 'android' ? 'Android (ready)' : 'iOS (notify me)'}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm text-slate-300 mb-1">Referral code (uppercase)*</label>
                    <input
                      type="text"
                      value={form.referralCode}
                      onChange={(e) => setForm({ ...form, referralCode: e.target.value.toUpperCase() })}
                      className="w-full rounded-xl bg-slate-800 border border-white/10 px-3 py-2 text-white uppercase tracking-wide focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="EXAMPLECODE"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-300 mb-1">Anything we should know? (optional)</label>
                    <textarea
                      rows={3}
                      value={form.note}
                      onChange={(e) => setForm({ ...form, note: e.target.value })}
                      className="w-full rounded-xl bg-slate-800 border border-white/10 px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-indigo-400"
                      placeholder="Your device, specialty, or what you want to test most."
                    />
                  </div>

                  {error && (
                    <p className="text-sm text-rose-300 bg-rose-500/10 border border-rose-500/30 rounded-lg px-3 py-2">
                      {error}
                    </p>
                  )}
                  {success && (
                    <p className="text-sm text-emerald-200 bg-emerald-500/10 border border-emerald-500/30 rounded-lg px-3 py-2">
                      {success}
                    </p>
                  )}

                  <button
                    type="submit"
                    disabled={submitting}
                    className="w-full rounded-xl bg-indigo-500 hover:bg-indigo-600 px-4 py-3 font-semibold text-white transition disabled:opacity-60 disabled:cursor-not-allowed shadow-lg shadow-indigo-900/30"
                  >
                    {submitting ? 'Submitting...' : 'Join closed testing'}
                  </button>
                  <p className="text-xs text-slate-400 text-center">
                    We respect your inbox. We’ll only email you about testing access.
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
