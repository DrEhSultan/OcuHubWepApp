import Head from 'next/head';
import { FormEvent, useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import type { GetServerSideProps } from 'next';
import { supabaseClient } from '../../lib/supabaseClient';
import { getAdminSessionFromRequest } from '../../lib/adminAuth';

interface LoginState {
  email: string;
  password: string;
}

const AdminLoginPage = () => {
  const router = useRouter();
  const [form, setForm] = useState<LoginState>({ email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // If Supabase OAuth already signed us in, bounce to /admin
  useEffect(() => {
    const checkSession = async () => {
      const { data } = await supabaseClient.auth.getSession();
      if (data.session) {
        router.replace('/admin');
      }
    };
    checkSession();
    const { data: subscription } = supabaseClient.auth.onAuthStateChange((_event, session) => {
      if (session) {
        router.replace('/admin');
      }
    });
    return () => {
      subscription?.subscription.unsubscribe();
    };
  }, [router]);

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await fetch('/api/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });

      if (!response.ok) {
        const data = await response.json();
        setError(data.error ?? 'Login failed');
        setLoading(false);
        return;
      }

      router.replace('/admin');
    } catch (err) {
      setError('Network error. Please try again.');
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>OcuHub Admin Login</title>
      </Head>
      <div className="min-h-screen bg-slate-950 flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-md rounded-2xl bg-slate-900/70 p-8 shadow-2xl border border-white/5">
          <div className="text-center mb-8">
            <p className="text-sm uppercase tracking-[0.3em] text-indigo-300">Internal Access</p>
            <h1 className="mt-2 text-3xl font-bold text-white">OcuHub Intelligence Console</h1>
            <p className="text-slate-400 mt-2 text-sm">
              Use your admin credentials to continue. This area is hidden from the public site.
            </p>
          </div>
          <div className="space-y-4">
            <button
              type="button"
              onClick={() =>
                supabaseClient.auth.signInWithOAuth({
                  provider: 'google',
                  options: { redirectTo: `${typeof window !== 'undefined' ? window.location.origin : ''}/admin` },
                })
              }
              className="w-full rounded-xl bg-white text-slate-900 font-semibold py-3 shadow-lg hover:shadow-xl transition flex items-center justify-center gap-2"
            >
              <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" className="w-5 h-5" />
              Continue with Google
            </button>
            <div className="flex items-center gap-3 text-xs text-slate-400">
              <div className="h-px flex-1 bg-white/10" />
              <span>or</span>
              <div className="h-px flex-1 bg-white/10" />
            </div>
          </div>
          <form onSubmit={handleSubmit} className="space-y-5 mt-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">Email</label>
              <input
                type="email"
                required
                value={form.email}
                onChange={(event) => setForm((prev) => ({ ...prev, email: event.target.value }))}
                className="w-full rounded-lg bg-slate-800/80 border border-slate-700 px-4 py-3 text-white focus:border-indigo-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/30"
                placeholder="admin@ocuhub.com"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1">Password</label>
              <input
                type="password"
                required
                value={form.password}
                onChange={(event) => setForm((prev) => ({ ...prev, password: event.target.value }))}
                className="w-full rounded-lg bg-slate-800/80 border border-slate-700 px-4 py-3 text-white focus:border-indigo-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/30"
                placeholder="••••••••"
              />
            </div>
            {error && <p className="text-sm text-rose-400 bg-rose-950/40 border border-rose-900/50 rounded-lg px-3 py-2">{error}</p>}
            <button
              type="submit"
              disabled={loading}
              className="w-full rounded-xl bg-gradient-to-r from-indigo-500 via-purple-500 to-blue-500 py-3 font-semibold text-white shadow-lg shadow-indigo-500/20 disabled:opacity-60"
            >
              {loading ? 'Signing in…' : 'Enter Admin Console'}
            </button>
          </form>
          <p className="text-center text-xs text-slate-500 mt-6">
            Need access? Contact the platform owner directly.
          </p>
        </div>
      </div>
    </>
  );
};

export const getServerSideProps: GetServerSideProps = async ({ req }) => {
  const session = getAdminSessionFromRequest(req);
  if (session) {
    return {
      redirect: {
        destination: '/admin',
        permanent: false,
      },
    };
  }

  return { props: {} };
};

export default AdminLoginPage;
