/**
 * Comprehensive Announcement & Survey Form
 * Supports all announcement fields with helpful descriptions
 */
import { useState } from 'react';

// Types
export type AnnouncementKind = 'announcement' | 'survey';
export type AnnouncementSurface = 'home_banner' | 'modal' | 'inbox' | 'tooltip';
export type AnnouncementImportance = 'low' | 'medium' | 'high';
export type AnnouncementActionType = 'none' | 'open_link' | 'open_screen' | 'open_tool';
export type AnnouncementRepeatMode = 'once' | 'per_app_open' | 'interval_hours';

export interface SurveyQuestion {
  id: string;
  type: 'single_choice' | 'multiple_choice' | 'text' | 'number' | 'yes_no' | 'rating';
  question: string;
  options?: string[];
  required?: boolean;
  placeholder?: string;
  min?: number;
  max?: number;
}

export interface AnnouncementFormData {
  title: string;
  message: string;
  kind: AnnouncementKind;
  surface: AnnouncementSurface;
  importance: AnnouncementImportance;
  action_type: AnnouncementActionType;
  action_value: string;
  cta_label: string;
  start_at: string;
  end_at: string;
  is_active: boolean;
  repeat_mode: AnnouncementRepeatMode;
  repeat_interval_hours: number;
  max_times_seen_per_user: number;
  dismissible: boolean;
  target_country: string;
  target_speciality: string;
  target_min_app_version: string;
  target_max_app_version: string;
  target_logged_in_only: boolean;
  target_anonymous_only: boolean;
  thumbnail: string;
  image_url: string;
  background_color: string;
  text_color: string;
  questions: SurveyQuestion[];
}


const DEFAULT_FORM: AnnouncementFormData = {
  title: '', message: '', kind: 'announcement', surface: 'home_banner', importance: 'medium',
  action_type: 'none', action_value: '', cta_label: '',
  start_at: new Date().toISOString().slice(0, 16), end_at: '', is_active: true,
  repeat_mode: 'once', repeat_interval_hours: 24, max_times_seen_per_user: 1, dismissible: true,
  target_country: '', target_speciality: '', target_min_app_version: '', target_max_app_version: '',
  target_logged_in_only: false, target_anonymous_only: false,
  thumbnail: '', image_url: '', background_color: '', text_color: '', questions: [],
};

const FIELD_DESC = {
  surface: {
    home_banner: '🏠 Carousel at top of home screen',
    modal: '📱 Full-screen popup',
    inbox: '📬 Notification center',
    tooltip: '💡 Contextual hint',
  },
  repeat_mode: {
    once: '🎯 Show only once per user',
    per_app_open: '🔄 Show once each app open',
    interval_hours: '⏰ Show after X hours',
  },
};

interface Props {
  initialData?: Partial<AnnouncementFormData>;
  onSubmit: (data: AnnouncementFormData) => Promise<void>;
  onCancel: () => void;
  isEditing?: boolean;
}

export default function AnnouncementForm({ initialData, onSubmit, onCancel, isEditing }: Props) {
  const [form, setForm] = useState<AnnouncementFormData>({ ...DEFAULT_FORM, ...initialData });
  const [activeTab, setActiveTab] = useState<string>('basic');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const updateField = <K extends keyof AnnouncementFormData>(key: K, value: AnnouncementFormData[K]) => {
    setForm(prev => ({ ...prev, [key]: value }));
  };

  const handleSubmit = async () => {
    if (!form.title.trim()) { setError('Title is required'); return; }
    if (form.kind === 'survey' && form.questions.length === 0) { setError('Survey must have at least one question'); return; }
    setSaving(true); setError(null);
    try { await onSubmit(form); } catch (err: any) { setError(err.message || 'Failed to save'); } finally { setSaving(false); }
  };

  const addQuestion = () => {
    const newQ: SurveyQuestion = { id: `q_${Date.now()}`, type: 'single_choice', question: '', options: ['Option 1', 'Option 2'], required: true };
    updateField('questions', [...form.questions, newQ]);
  };

  const updateQuestion = (idx: number, updates: Partial<SurveyQuestion>) => {
    const newQ = [...form.questions]; newQ[idx] = { ...newQ[idx], ...updates }; updateField('questions', newQ);
  };

  const removeQuestion = (idx: number) => updateField('questions', form.questions.filter((_, i) => i !== idx));

  const tabs = [
    { id: 'basic', label: '📝 Basic' }, { id: 'action', label: '🎯 Action' }, { id: 'schedule', label: '📅 Schedule' },
    { id: 'repeat', label: '🔄 Repeat' }, { id: 'targeting', label: '🎯 Target' }, { id: 'visual', label: '🎨 Visual' },
    ...(form.kind === 'survey' ? [{ id: 'questions', label: '❓ Questions' }] : []),
  ];


  return (
    <div className="bg-slate-900 rounded-2xl border border-white/10 overflow-hidden">
      <div className="flex overflow-x-auto border-b border-white/10 bg-slate-800/50">
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-3 text-sm font-medium whitespace-nowrap ${activeTab === tab.id ? 'border-b-2 border-indigo-500 text-indigo-300' : 'text-slate-400 hover:text-slate-300'}`}>
            {tab.label}
          </button>
        ))}
      </div>

      {/* Sticky Header - Title & Message always visible */}
      <div className="sticky top-0 z-10 bg-slate-900 border-b border-white/10 px-6 py-4 space-y-4">
        {error && <div className="bg-rose-500/20 border border-rose-500/50 rounded-lg px-4 py-3 text-rose-200 text-sm">{error}</div>}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="text-xs font-medium text-slate-400 mb-1 block">Title *</label>
            <input type="text" value={form.title} onChange={e => updateField('title', e.target.value)} maxLength={100}
              placeholder="🎉 New Feature: Dark Mode" className="w-full bg-slate-800 border border-white/10 rounded-lg px-3 py-2 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none text-sm" />
          </div>
          <div>
            <label className="text-xs font-medium text-slate-400 mb-1 block">Message</label>
            <input type="text" value={form.message} onChange={e => updateField('message', e.target.value)} maxLength={300}
              placeholder="Description text..." className="w-full bg-slate-800 border border-white/10 rounded-lg px-3 py-2 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none text-sm" />
          </div>
        </div>
      </div>

      <div className="p-6 space-y-6 max-h-[60vh] overflow-y-auto">
        {activeTab === 'basic' && (
          <div className="space-y-5">
            <Section title="Type" desc="Announcement or Survey/Quiz">
              <div className="grid grid-cols-2 gap-3">
                {(['announcement', 'survey'] as const).map(k => (
                  <button key={k} onClick={() => updateField('kind', k)}
                    className={`p-4 rounded-xl border text-left ${form.kind === k ? 'border-indigo-500 bg-indigo-500/20 text-white' : 'border-white/10 bg-slate-800/50 text-slate-300'}`}>
                    <div className="font-medium">{k === 'announcement' ? '📢 Announcement' : '📋 Survey/Quiz'}</div>
                  </button>
                ))}
              </div>
            </Section>
            <Section title="Title *" desc="Main headline (max 100 chars)">
              <input type="text" value={form.title} onChange={e => updateField('title', e.target.value)} maxLength={100}
                placeholder="🎉 New Feature: Dark Mode" className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
              <div className="text-xs text-slate-500 mt-1">{form.title.length}/100</div>
            </Section>
            <Section title="Message" desc="Description (max 300 chars)">
              <textarea value={form.message} onChange={e => updateField('message', e.target.value)} maxLength={300} rows={3}
                className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none resize-none" />
              <div className="text-xs text-slate-500 mt-1">{form.message.length}/300</div>
            </Section>
            <Section title="Surface *" desc="Where to show">
              <div className="grid grid-cols-2 gap-3">
                {(['home_banner', 'modal', 'inbox', 'tooltip'] as const).map(s => (
                  <button key={s} onClick={() => updateField('surface', s)}
                    className={`p-3 rounded-xl border text-left ${form.surface === s ? 'border-indigo-500 bg-indigo-500/20 text-white' : 'border-white/10 bg-slate-800/50 text-slate-300'}`}>
                    <div className="font-medium text-sm">{s.replace('_', ' ')}</div>
                    <div className="text-xs text-slate-400 mt-1">{FIELD_DESC.surface[s]}</div>
                  </button>
                ))}
              </div>
            </Section>
            <Section title="Importance *" desc="Display order and styling">
              <div className="grid grid-cols-3 gap-3">
                {(['high', 'medium', 'low'] as const).map(i => (
                  <button key={i} onClick={() => updateField('importance', i)}
                    className={`p-3 rounded-xl border text-center ${form.importance === i ? (i === 'high' ? 'border-rose-500 bg-rose-500/20 text-rose-200' : i === 'medium' ? 'border-amber-500 bg-amber-500/20 text-amber-200' : 'border-blue-500 bg-blue-500/20 text-blue-200') : 'border-white/10 bg-slate-800/50 text-slate-300'}`}>
                    <div className="font-medium capitalize">{i}</div>
                  </button>
                ))}
              </div>
            </Section>
          </div>
        )}


        {activeTab === 'action' && (
          <div className="space-y-5">
            <Section title="Action Type" desc="What happens on tap">
              <div className="grid grid-cols-2 gap-3">
                {(['none', 'open_link', 'open_screen', 'open_tool'] as const).map(a => (
                  <button key={a} onClick={() => updateField('action_type', a)}
                    className={`p-3 rounded-xl border text-left ${form.action_type === a ? 'border-indigo-500 bg-indigo-500/20 text-white' : 'border-white/10 bg-slate-800/50 text-slate-300'}`}>
                    <div className="font-medium text-sm capitalize">{a.replace('_', ' ')}</div>
                  </button>
                ))}
              </div>
            </Section>
            {form.action_type === 'open_link' && (
              <Section title="URL" desc="Full URL to open in browser">
                <input type="url" value={form.action_value} onChange={e => updateField('action_value', e.target.value)}
                  placeholder="https://example.com" className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
              </Section>
            )}
            {form.action_type === 'open_screen' && (
              <Section title="Screen" desc="Select app screen to navigate to">
                <select value={form.action_value} onChange={e => updateField('action_value', e.target.value)}
                  className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none">
                  <option value="">-- Select Screen --</option>
                  <optgroup label="Main Screens">
                    <option value="Home">🏠 Home</option>
                    <option value="VisionTools">👁️ Vision Tools</option>
                    <option value="DecisionSupport">🧠 Decision Support</option>
                    <option value="More">⋯ More</option>
                    <option value="Settings">⚙️ Settings</option>
                  </optgroup>
                  <optgroup label="Auth & Account">
                    <option value="SignIn">🔐 Sign In Modal</option>
                    <option value="Login">🔑 Login Screen</option>
                    <option value="Profile">👤 Profile</option>
                  </optgroup>
                  <optgroup label="Other">
                    <option value="AnnouncementInbox">📬 Announcement Inbox</option>
                    <option value="Calibration">📏 Screen Calibration</option>
                    <option value="Feedback">💬 Feedback</option>
                  </optgroup>
                </select>
              </Section>
            )}
            {form.action_type === 'open_tool' && (
              <Section title="Tool" desc="Select tool to open">
                <select value={form.action_value} onChange={e => updateField('action_value', e.target.value)}
                  className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none">
                  <option value="">-- Select Tool --</option>
                  <optgroup label="👶 Pediatrics">
                    <option value="pediatrics/pediatric-glasses">Pediatric Glasses</option>
                    <option value="pediatrics/amblyopia-treatment">Amblyopia Treatment</option>
                    <option value="pediatrics/pediatric-iol">Pediatric IOL</option>
                    <option value="pediatrics/axial-estimator">Axial Estimator</option>
                    <option value="pediatrics/visual-maturation">Visual Maturation</option>
                  </optgroup>
                  <optgroup label="🟢 Glaucoma">
                    <option value="glaucoma/iop-correction">IOP Correction</option>
                    <option value="glaucoma/corneal-diameter">Corneal Diameter</option>
                    <option value="glaucoma/schiotz">Schiotz Tonometry</option>
                  </optgroup>
                  <optgroup label="👀 Strabismus">
                    <option value="strabismus/strabismus-surgery-dose">Strabismus Surgery Dose</option>
                    <option value="strabismus/prismatic-effect-glasses">Prismatic Effect Glasses</option>
                    <option value="strabismus/prism-summation">Prism Summation</option>
                    <option value="strabismus/parks-3-step-test">Parks 3-Step Test</option>
                    <option value="strabismus/kestenbaum-planner">Kestenbaum Planner</option>
                  </optgroup>
                  <optgroup label="👓 Optometry">
                    <option value="optometry/spectacle-to-cl">Spectacle to CL</option>
                    <option value="optometry/retinoscopy-to-rx">Retinoscopy to Rx</option>
                    <option value="optometry/va-from-re">VA from RE</option>
                    <option value="optometry/va-notation">VA Notation</option>
                    <option value="optometry/near-add-estimator">Near Add Estimator</option>
                  </optgroup>
                  <optgroup label="🔬 Anterior Segment / Refractive">
                    <option value="anterior-segment/iol-calculator">IOL Calculator</option>
                    <option value="anterior-segment/lasik-ectasia-risk">LASIK Ectasia Risk</option>
                    <option value="anterior-segment/lasik-guide">LASIK Guide</option>
                    <option value="anterior-segment/suture-adjustment">Suture Adjustment</option>
                  </optgroup>
                  <optgroup label="📊 Vision Tests">
                    <option value="vision-tests/e-chart-vision-test">E Chart</option>
                    <option value="vision-tests/landolt-c-chart">Landolt C Chart</option>
                    <option value="vision-tests/numbers-chart">Numbers Chart</option>
                    <option value="vision-tests/logmar-chart">LogMAR Chart</option>
                    <option value="vision-tests/arabic-va-chart">Arabic VA Chart</option>
                    <option value="vision-tests/astigmatic-fan">Astigmatic Fan</option>
                  </optgroup>
                  <optgroup label="📖 Near Reading">
                    <option value="near-reading/near-english-chart">Near English Chart</option>
                    <option value="near-reading/near-arabic-chart">Near Arabic Chart</option>
                    <option value="near-reading/near-numbers-chart">Near Numbers Chart</option>
                  </optgroup>
                  <optgroup label="🎨 Contrast Sensitivity">
                    <option value="contrast-sensitivity-tests/contrast-e-chart">Contrast E Chart</option>
                    <option value="contrast-sensitivity-tests/contrast-logmar">Contrast LogMAR</option>
                    <option value="contrast-sensitivity-tests/contrast-numbers">Contrast Numbers</option>
                    <option value="contrast-sensitivity-tests/contrast-landolt-c">Contrast Landolt C</option>
                    <option value="contrast-sensitivity-tests/contrast-arabic">Contrast Arabic</option>
                    <option value="contrast-sensitivity-tests/contrast-kids-shapes">Contrast Kids Shapes</option>
                  </optgroup>
                  <optgroup label="🧒 Pediatric Vision Tools">
                    <option value="pediatric-tools/kids-fixation-target">Kids Fixation Target</option>
                    <option value="pediatric-tools/optokinetic-drum">Optokinetic Drum</option>
                    <option value="pediatric-tools/shaped-vision-chart">Shaped Vision Chart</option>
                  </optgroup>
                  <optgroup label="🔦 Strabismus Tools">
                    <option value="strabismus-tools/light-target">Light Target</option>
                    <option value="strabismus-tools/worth-4-dots-test">Worth 4 Dots Test</option>
                  </optgroup>
                  <optgroup label="👁️ Retina">
                    <option value="retina/amsler-grid">Amsler Grid</option>
                  </optgroup>
                </select>
              </Section>
            )}
            <Section title="CTA Label" desc="Button text (max 20 chars)">
              <input type="text" value={form.cta_label} onChange={e => updateField('cta_label', e.target.value)} maxLength={20}
                placeholder="Learn More" className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="Dismissible" desc="Allow users to close">
              <Toggle checked={form.dismissible} onChange={v => updateField('dismissible', v)} label={form.dismissible ? 'Can dismiss' : 'Cannot dismiss'} />
            </Section>
          </div>
        )}

        {activeTab === 'schedule' && (
          <div className="space-y-5">
            <Section title="Start Date *" desc="When to start showing">
              <input type="datetime-local" value={form.start_at} onChange={e => updateField('start_at', e.target.value)}
                className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="End Date" desc="When to stop (empty = never)">
              <input type="datetime-local" value={form.end_at} onChange={e => updateField('end_at', e.target.value)}
                className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="Active" desc="Inactive = draft mode">
              <Toggle checked={form.is_active} onChange={v => updateField('is_active', v)} label={form.is_active ? '✅ Active' : '⏸️ Inactive'} />
            </Section>
          </div>
        )}

        {activeTab === 'repeat' && (
          <div className="space-y-5">
            <Section title="Repeat Mode *" desc="How often to show">
              <div className="space-y-3">
                {(['once', 'per_app_open', 'interval_hours'] as const).map(m => (
                  <button key={m} onClick={() => updateField('repeat_mode', m)}
                    className={`w-full p-4 rounded-xl border text-left ${form.repeat_mode === m ? 'border-indigo-500 bg-indigo-500/20 text-white' : 'border-white/10 bg-slate-800/50 text-slate-300'}`}>
                    <div className="font-medium">{m === 'once' ? '🎯 Once' : m === 'per_app_open' ? '🔄 Per App Open' : '⏰ Interval'}</div>
                    <div className="text-xs text-slate-400 mt-1">{FIELD_DESC.repeat_mode[m]}</div>
                  </button>
                ))}
              </div>
            </Section>
            {form.repeat_mode === 'interval_hours' && (
              <Section title="Interval (Hours)" desc="Hours between displays">
                <input type="number" value={form.repeat_interval_hours} onChange={e => updateField('repeat_interval_hours', parseInt(e.target.value) || 24)} min={1}
                  className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none" />
              </Section>
            )}
            <Section title="Max Times" desc="Max views per user (0 = unlimited)">
              <input type="number" value={form.max_times_seen_per_user} onChange={e => updateField('max_times_seen_per_user', parseInt(e.target.value) || 0)} min={0}
                className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none" />
            </Section>
          </div>
        )}


        {activeTab === 'targeting' && (
          <div className="space-y-5">
            <Section title="Country" desc="ISO code (empty = all)">
              <input type="text" value={form.target_country} onChange={e => updateField('target_country', e.target.value)}
                placeholder="US, GB, SA" className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="Specialty" desc="Medical specialty (empty = all)">
              <select value={form.target_speciality} onChange={e => updateField('target_speciality', e.target.value)}
                className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-indigo-500 focus:outline-none">
                <option value="">All</option>
                <option value="ophthalmology">Ophthalmology</option>
                <option value="optometry">Optometry</option>
                <option value="retina">Retina</option>
                <option value="glaucoma">Glaucoma</option>
              </select>
            </Section>
            <Section title="App Version" desc="Min/Max version range">
              <div className="grid grid-cols-2 gap-4">
                <input type="text" value={form.target_min_app_version} onChange={e => updateField('target_min_app_version', e.target.value)}
                  placeholder="Min: 2.0.0" className="bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
                <input type="text" value={form.target_max_app_version} onChange={e => updateField('target_max_app_version', e.target.value)}
                  placeholder="Max: 2.9.9" className="bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
              </div>
            </Section>
            <Section title="Login Status" desc="Filter by auth status">
              <div className="space-y-2">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input type="radio" checked={!form.target_logged_in_only && !form.target_anonymous_only}
                    onChange={() => { updateField('target_logged_in_only', false); updateField('target_anonymous_only', false); }} className="w-4 h-4" />
                  <span className="text-slate-300">All Users</span>
                </label>
                <label className="flex items-center gap-3 cursor-pointer">
                  <input type="radio" checked={form.target_logged_in_only}
                    onChange={() => { updateField('target_logged_in_only', true); updateField('target_anonymous_only', false); }} className="w-4 h-4" />
                  <span className="text-slate-300">Logged In Only</span>
                </label>
                <label className="flex items-center gap-3 cursor-pointer">
                  <input type="radio" checked={form.target_anonymous_only}
                    onChange={() => { updateField('target_logged_in_only', false); updateField('target_anonymous_only', true); }} className="w-4 h-4" />
                  <span className="text-slate-300">Anonymous Only</span>
                </label>
              </div>
            </Section>
          </div>
        )}

        {activeTab === 'visual' && (
          <div className="space-y-5">
            <Section title="Thumbnail URL" desc="Small image (60x60px)">
              <input type="url" value={form.thumbnail} onChange={e => updateField('thumbnail', e.target.value)}
                placeholder="https://..." className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="Full Image URL" desc="Large image for modals">
              <input type="url" value={form.image_url} onChange={e => updateField('image_url', e.target.value)}
                placeholder="https://..." className="w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
            </Section>
            <Section title="Colors" desc="Custom background/text colors">
              <div className="grid grid-cols-2 gap-4">
                <input type="text" value={form.background_color} onChange={e => updateField('background_color', e.target.value)}
                  placeholder="Background: #1a1a2e" className="bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
                <input type="text" value={form.text_color} onChange={e => updateField('text_color', e.target.value)}
                  placeholder="Text: #ffffff" className="bg-slate-800 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none" />
              </div>
            </Section>
          </div>
        )}


        {activeTab === 'questions' && form.kind === 'survey' && (
          <div className="space-y-5">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-white">Survey Questions</h3>
              <button onClick={addQuestion} className="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-medium">+ Add Question</button>
            </div>
            {form.questions.length === 0 && <p className="text-center py-8 text-slate-400">No questions yet. Click &quot;Add Question&quot; to start.</p>}
            {form.questions.map((q, idx) => (
              <div key={q.id} className="bg-slate-800/50 border border-white/10 rounded-xl p-4 space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-indigo-300">Question {idx + 1}</span>
                  <button onClick={() => removeQuestion(idx)} className="text-rose-400 hover:text-rose-300 text-sm">Remove</button>
                </div>
                <div>
                  <label className="text-xs text-slate-400 mb-1 block">Type</label>
                  <select value={q.type} onChange={e => updateQuestion(idx, { type: e.target.value as SurveyQuestion['type'] })}
                    className="w-full bg-slate-700 border border-white/10 rounded-lg px-3 py-2 text-white text-sm">
                    <option value="single_choice">Single Choice</option>
                    <option value="multiple_choice">Multiple Choice</option>
                    <option value="yes_no">Yes / No</option>
                    <option value="text">Text Input</option>
                    <option value="number">Number Input</option>
                    <option value="rating">Rating (1-5)</option>
                  </select>
                </div>
                <div>
                  <label className="text-xs text-slate-400 mb-1 block">Question *</label>
                  <input type="text" value={q.question} onChange={e => updateQuestion(idx, { question: e.target.value })}
                    placeholder="What is your specialty?" className="w-full bg-slate-700 border border-white/10 rounded-lg px-3 py-2 text-white text-sm placeholder-slate-500" />
                </div>
                {(q.type === 'single_choice' || q.type === 'multiple_choice') && (
                  <div>
                    <label className="text-xs text-slate-400 mb-1 block">Options (one per line)</label>
                    <textarea value={(q.options || []).join('\n')} onChange={e => updateQuestion(idx, { options: e.target.value.split('\n').filter(o => o.trim()) })}
                      rows={4} className="w-full bg-slate-700 border border-white/10 rounded-lg px-3 py-2 text-white text-sm resize-none" />
                  </div>
                )}
                {q.type === 'number' && (
                  <div className="grid grid-cols-2 gap-4">
                    <div><label className="text-xs text-slate-400 mb-1 block">Min</label>
                      <input type="number" value={q.min || ''} onChange={e => updateQuestion(idx, { min: parseInt(e.target.value) || undefined })} className="w-full bg-slate-700 border border-white/10 rounded-lg px-3 py-2 text-white text-sm" /></div>
                    <div><label className="text-xs text-slate-400 mb-1 block">Max</label>
                      <input type="number" value={q.max || ''} onChange={e => updateQuestion(idx, { max: parseInt(e.target.value) || undefined })} className="w-full bg-slate-700 border border-white/10 rounded-lg px-3 py-2 text-white text-sm" /></div>
                  </div>
                )}
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" checked={q.required !== false} onChange={e => updateQuestion(idx, { required: e.target.checked })} className="w-4 h-4" />
                  <span className="text-sm text-slate-300">Required</span>
                </label>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="border-t border-white/10 px-6 py-4 flex items-center justify-between bg-slate-800/50">
        <button onClick={onCancel} className="px-4 py-2 text-slate-400 hover:text-white">Cancel</button>
        <div className="flex gap-3">
          <button onClick={() => { updateField('is_active', false); handleSubmit(); }} className="px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg text-sm font-medium">Save Draft</button>
          <button onClick={handleSubmit} disabled={saving} className="px-6 py-2 bg-indigo-500 hover:bg-indigo-600 disabled:opacity-50 text-white rounded-lg text-sm font-medium">
            {saving ? 'Saving...' : isEditing ? 'Update' : form.is_active ? 'Publish' : 'Schedule'}
          </button>
        </div>
      </div>
    </div>
  );
}

function Section({ title, desc, children }: { title: string; desc: string; children: React.ReactNode }) {
  return (<div><label className="block text-sm font-medium text-white mb-1">{title}</label><p className="text-xs text-slate-400 mb-3">{desc}</p>{children}</div>);
}

function Toggle({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: string }) {
  return (
    <button onClick={() => onChange(!checked)} className="flex items-center gap-3 w-full text-left">
      <div className={`w-12 h-6 rounded-full transition-colors ${checked ? 'bg-indigo-500' : 'bg-slate-600'} relative`}>
        <div className={`w-5 h-5 rounded-full bg-white absolute top-0.5 transition-transform ${checked ? 'translate-x-6' : 'translate-x-0.5'}`} />
      </div>
      <span className="text-sm text-slate-300">{label}</span>
    </button>
  );
}
