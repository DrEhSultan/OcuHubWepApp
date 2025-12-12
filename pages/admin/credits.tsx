import Head from 'next/head';
import { useEffect, useState, useCallback } from 'react';
import type { GetServerSideProps } from 'next';
import { getAdminSessionFromRequest } from '../../lib/adminAuth';
import type { AdminSession } from '../../types/admin';
import Link from 'next/link';

interface AdminPageProps {
  admin: AdminSession;
}

interface AssetType {
  id: string;
  name: string;
  display_name: string;
  description: string | null;
  icon: string | null;
  sort_order: number;
  is_active: boolean;
}

interface Site {
  id: string;
  asset_type_id: string;
  name: string;
  display_name: string;
  website_url: string | null;
  attribution_format: string | null;
  description: string | null;
  logo_url: string | null;
  sort_order: number;
  is_active: boolean;
}

interface CreditLink {
  id: string;
  site_id: string;
  title: string;
  url: string;
  author: string | null;
  description: string | null;
  sort_order: number;
  is_active: boolean;
}

type ModalType = 'asset-type' | 'site' | 'link' | null;

const CreditsAdminPage = ({ admin }: AdminPageProps) => {
  const [assetTypes, setAssetTypes] = useState<AssetType[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  const [links, setLinks] = useState<CreditLink[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Modal state
  const [modalType, setModalType] = useState<ModalType>(null);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [selectedAssetType, setSelectedAssetType] = useState<string | null>(null);
  const [selectedSite, setSelectedSite] = useState<string | null>(null);

  // Form state
  const [formData, setFormData] = useState<Record<string, any>>({});
  const [saving, setSaving] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/admin/credits');
      if (response.status === 401) {
        window.location.href = '/admin/login';
        return;
      }
      if (!response.ok) {
        const payload = await response.json();
        setError(payload.error ?? 'Failed to load credits data');
        return;
      }
      const data = await response.json();
      setAssetTypes(data.assetTypes || []);
      setSites(data.sites || []);
      setLinks(data.links || []);
    } catch (err) {
      setError('Network error while loading credits data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const openModal = (type: ModalType, item?: any) => {
    setModalType(type);
    setEditingItem(item || null);
    if (item) {
      setFormData({ ...item });
    } else {
      // Default values for new items
      if (type === 'asset-type') {
        setFormData({ name: '', display_name: '', description: '', icon: '', sort_order: 0, is_active: true });
      } else if (type === 'site') {
        setFormData({ asset_type_id: selectedAssetType || '', name: '', display_name: '', website_url: '', attribution_format: '', description: '', logo_url: '', sort_order: 0, is_active: true });
      } else if (type === 'link') {
        setFormData({ site_id: selectedSite || '', title: '', url: '', author: '', description: '', sort_order: 0, is_active: true });
      }
    }
  };

  const closeModal = () => {
    setModalType(null);
    setEditingItem(null);
    setFormData({});
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const isEdit = !!editingItem;
      const method = isEdit ? 'PUT' : 'POST';
      const url = isEdit
        ? `/api/admin/credits?type=${modalType}&id=${editingItem.id}`
        : `/api/admin/credits?type=${modalType}`;

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const payload = await response.json();
        alert(payload.error || 'Failed to save');
        return;
      }

      await loadData();
      closeModal();
    } catch (err) {
      alert('Error saving data');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (type: string, id: string, name: string) => {
    if (!confirm(`Are you sure you want to delete "${name}"?`)) return;

    try {
      const response = await fetch(`/api/admin/credits?type=${type}&id=${id}`, {
        method: 'DELETE',
      });

      if (!response.ok && response.status !== 204) {
        const payload = await response.json();
        alert(payload.error || 'Failed to delete');
        return;
      }

      await loadData();
    } catch (err) {
      alert('Error deleting item');
    }
  };

  const handleLogout = async () => {
    await fetch('/api/admin/logout', { method: 'POST' });
    window.location.href = '/admin/login';
  };

  const filteredSites = selectedAssetType
    ? sites.filter(s => s.asset_type_id === selectedAssetType)
    : sites;

  const filteredLinks = selectedSite
    ? links.filter(l => l.site_id === selectedSite)
    : links;

  const getAssetTypeName = (id: string) => assetTypes.find(t => t.id === id)?.display_name || 'Unknown';
  const getSiteName = (id: string) => sites.find(s => s.id === id)?.display_name || 'Unknown';

  return (
    <>
      <Head>
        <title>Credits Management - OcuHub Admin</title>
      </Head>
      <div className="min-h-screen bg-slate-950 text-white">
        {/* Header */}
        <header className="border-b border-white/5 bg-slate-900/80 backdrop-blur sticky top-0 z-50">
          <div className="max-w-7xl mx-auto flex items-center justify-between px-4 py-2">
            <div className="flex items-center gap-6">
              <Link href="/admin" className="text-lg font-semibold text-white hover:text-indigo-300">
                OcuHub <span className="text-indigo-400">Admin</span>
              </Link>
              <span className="text-slate-400">→</span>
              <h1 className="text-lg font-semibold">Credits & Acknowledgments</h1>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-xs text-slate-500">{admin.role}</span>
              <button
                onClick={handleLogout}
                className="px-2 py-1 text-xs text-slate-400 hover:text-white hover:bg-slate-800 rounded"
              >
                Sign out
              </button>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 py-8">
          {error && (
            <div className="rounded-xl border border-rose-400/30 bg-rose-950/40 px-4 py-3 text-sm text-rose-200 mb-6">
              {error}
            </div>
          )}

          {loading ? (
            <div className="text-center py-12 text-slate-400">Loading credits data...</div>
          ) : (
            <div className="grid gap-6 lg:grid-cols-3">
              {/* Asset Types Column */}
              <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-semibold">Asset Types</h2>
                  <button
                    onClick={() => openModal('asset-type')}
                    className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg"
                  >
                    + Add Type
                  </button>
                </div>
                <div className="space-y-2">
                  {assetTypes.map(type => (
                    <div
                      key={type.id}
                      className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                        selectedAssetType === type.id
                          ? 'border-indigo-500 bg-indigo-500/10'
                          : 'border-white/5 bg-slate-800/50 hover:bg-slate-800'
                      }`}
                      onClick={() => {
                        setSelectedAssetType(type.id);
                        setSelectedSite(null);
                      }}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          {type.icon && <span className="text-lg">{type.icon}</span>}
                          <span className="font-medium">{type.display_name}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <span className={`text-xs px-2 py-0.5 rounded ${type.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                            {type.is_active ? 'Active' : 'Inactive'}
                          </span>
                          <button
                            onClick={(e) => { e.stopPropagation(); openModal('asset-type', type); }}
                            className="p-1 text-slate-400 hover:text-white"
                          >
                            ✏️
                          </button>
                          <button
                            onClick={(e) => { e.stopPropagation(); handleDelete('asset-type', type.id, type.display_name); }}
                            className="p-1 text-slate-400 hover:text-rose-400"
                          >
                            🗑️
                          </button>
                        </div>
                      </div>
                      <div className="text-xs text-slate-400 mt-1">
                        {sites.filter(s => s.asset_type_id === type.id).length} sites
                      </div>
                    </div>
                  ))}
                  {assetTypes.length === 0 && (
                    <div className="text-center py-8 text-slate-500">No asset types yet</div>
                  )}
                </div>
              </div>

              {/* Sites Column */}
              <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-semibold">
                    Sites {selectedAssetType && <span className="text-sm text-slate-400">({getAssetTypeName(selectedAssetType)})</span>}
                  </h2>
                  <button
                    onClick={() => openModal('site')}
                    disabled={!selectedAssetType}
                    className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    + Add Site
                  </button>
                </div>
                <div className="space-y-2">
                  {filteredSites.map(site => (
                    <div
                      key={site.id}
                      className={`p-3 rounded-lg border cursor-pointer transition-colors ${
                        selectedSite === site.id
                          ? 'border-indigo-500 bg-indigo-500/10'
                          : 'border-white/5 bg-slate-800/50 hover:bg-slate-800'
                      }`}
                      onClick={() => setSelectedSite(site.id)}
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-medium">{site.display_name}</span>
                        <div className="flex items-center gap-1">
                          <span className={`text-xs px-2 py-0.5 rounded ${site.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                            {site.is_active ? 'Active' : 'Inactive'}
                          </span>
                          <button
                            onClick={(e) => { e.stopPropagation(); openModal('site', site); }}
                            className="p-1 text-slate-400 hover:text-white"
                          >
                            ✏️
                          </button>
                          <button
                            onClick={(e) => { e.stopPropagation(); handleDelete('site', site.id, site.display_name); }}
                            className="p-1 text-slate-400 hover:text-rose-400"
                          >
                            🗑️
                          </button>
                        </div>
                      </div>
                      {site.website_url && (
                        <a
                          href={site.website_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-xs text-indigo-400 hover:underline"
                          onClick={(e) => e.stopPropagation()}
                        >
                          {site.website_url}
                        </a>
                      )}
                      <div className="text-xs text-slate-400 mt-1">
                        {links.filter(l => l.site_id === site.id).length} credits
                      </div>
                    </div>
                  ))}
                  {filteredSites.length === 0 && (
                    <div className="text-center py-8 text-slate-500">
                      {selectedAssetType ? 'No sites for this type' : 'Select an asset type'}
                    </div>
                  )}
                </div>
              </div>

              {/* Links Column */}
              <div className="bg-slate-900/60 border border-white/5 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-semibold">
                    Credits {selectedSite && <span className="text-sm text-slate-400">({getSiteName(selectedSite)})</span>}
                  </h2>
                  <button
                    onClick={() => openModal('link')}
                    disabled={!selectedSite}
                    className="px-3 py-1.5 text-xs font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    + Add Credit
                  </button>
                </div>
                <div className="space-y-2 max-h-[600px] overflow-y-auto">
                  {filteredLinks.map(link => (
                    <div
                      key={link.id}
                      className="p-3 rounded-lg border border-white/5 bg-slate-800/50"
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-medium text-sm">{link.title}</span>
                        <div className="flex items-center gap-1">
                          <span className={`text-xs px-2 py-0.5 rounded ${link.is_active ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-500/20 text-slate-400'}`}>
                            {link.is_active ? 'Active' : 'Inactive'}
                          </span>
                          <button
                            onClick={() => openModal('link', link)}
                            className="p-1 text-slate-400 hover:text-white"
                          >
                            ✏️
                          </button>
                          <button
                            onClick={() => handleDelete('link', link.id, link.title)}
                            className="p-1 text-slate-400 hover:text-rose-400"
                          >
                            🗑️
                          </button>
                        </div>
                      </div>
                      {link.author && (
                        <div className="text-xs text-slate-400">by {link.author}</div>
                      )}
                      <a
                        href={link.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-xs text-indigo-400 hover:underline break-all"
                      >
                        {link.url}
                      </a>
                    </div>
                  ))}
                  {filteredLinks.length === 0 && (
                    <div className="text-center py-8 text-slate-500">
                      {selectedSite ? 'No credits for this site' : 'Select a site'}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}
        </main>

        {/* Modal */}
        {modalType && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm px-4">
            <div className="w-full max-w-lg rounded-2xl bg-slate-950 border border-white/10 shadow-2xl p-6">
              <h3 className="text-lg font-semibold mb-4">
                {editingItem ? 'Edit' : 'Add'} {modalType === 'asset-type' ? 'Asset Type' : modalType === 'site' ? 'Site' : 'Credit Link'}
              </h3>

              <div className="space-y-4">
                {modalType === 'asset-type' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Name (slug)</label>
                      <input
                        type="text"
                        value={formData.name || ''}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., icon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Display Name</label>
                      <input
                        type="text"
                        value={formData.display_name || ''}
                        onChange={(e) => setFormData({ ...formData, display_name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Icons"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Icon (Ionicons name)</label>
                      <input
                        type="text"
                        value={formData.icon || ''}
                        onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., shapes-outline"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Description</label>
                      <textarea
                        value={formData.description || ''}
                        onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        rows={2}
                      />
                    </div>
                  </>
                )}

                {modalType === 'site' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Asset Type</label>
                      <select
                        value={formData.asset_type_id || ''}
                        onChange={(e) => setFormData({ ...formData, asset_type_id: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                      >
                        <option value="">Select type...</option>
                        {assetTypes.map(t => (
                          <option key={t.id} value={t.id}>{t.display_name}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Name (slug)</label>
                      <input
                        type="text"
                        value={formData.name || ''}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., flaticon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Display Name</label>
                      <input
                        type="text"
                        value={formData.display_name || ''}
                        onChange={(e) => setFormData({ ...formData, display_name: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Flaticon"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Website URL</label>
                      <input
                        type="url"
                        value={formData.website_url || ''}
                        onChange={(e) => setFormData({ ...formData, website_url: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="https://www.flaticon.com"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Attribution Format (optional)</label>
                      <textarea
                        value={formData.attribution_format || ''}
                        onChange={(e) => setFormData({ ...formData, attribution_format: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white text-sm"
                        rows={2}
                        placeholder='<a href="{url}" title="{title}">{title} by {author}</a>'
                      />
                    </div>
                  </>
                )}

                {modalType === 'link' && (
                  <>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Site</label>
                      <select
                        value={formData.site_id || ''}
                        onChange={(e) => setFormData({ ...formData, site_id: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                      >
                        <option value="">Select site...</option>
                        {sites.map(s => (
                          <option key={s.id} value={s.id}>{s.display_name}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Title</label>
                      <input
                        type="text"
                        value={formData.title || ''}
                        onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Introduction icons"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">URL</label>
                      <input
                        type="url"
                        value={formData.url || ''}
                        onChange={(e) => setFormData({ ...formData, url: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="https://www.flaticon.com/free-icons/introduction"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-1">Author</label>
                      <input
                        type="text"
                        value={formData.author || ''}
                        onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                        placeholder="e.g., Aficons studio"
                      />
                    </div>
                  </>
                )}

                <div className="flex items-center gap-4">
                  <div>
                    <label className="block text-sm text-slate-400 mb-1">Sort Order</label>
                    <input
                      type="number"
                      value={formData.sort_order || 0}
                      onChange={(e) => setFormData({ ...formData, sort_order: parseInt(e.target.value) || 0 })}
                      className="w-24 px-3 py-2 bg-slate-800 border border-white/10 rounded-lg text-white"
                    />
                  </div>
                  <div className="flex items-center gap-2 mt-6">
                    <input
                      type="checkbox"
                      id="is_active"
                      checked={formData.is_active !== false}
                      onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                      className="w-4 h-4"
                    />
                    <label htmlFor="is_active" className="text-sm text-slate-400">Active</label>
                  </div>
                </div>
              </div>

              <div className="flex justify-end gap-3 mt-6">
                <button
                  onClick={closeModal}
                  className="px-4 py-2 text-sm text-slate-400 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSave}
                  disabled={saving}
                  className="px-4 py-2 text-sm font-medium bg-indigo-500 hover:bg-indigo-600 rounded-lg disabled:opacity-50"
                >
                  {saving ? 'Saving...' : 'Save'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
};

export const getServerSideProps: GetServerSideProps = async ({ req }) => {
  const admin = getAdminSessionFromRequest(req);
  if (!admin) {
    return {
      redirect: {
        destination: '/admin/login',
        permanent: false,
      },
    };
  }
  return { props: { admin } };
};

export default CreditsAdminPage;
