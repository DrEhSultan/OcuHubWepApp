/**
 * Compact Announcement & Survey Form
 * All settings in one view, Questions tab only for surveys
 */
import { useState, useEffect } from 'react';

// Types
export type AnnouncementKind = 'announcement' | 'survey';
export type AnnouncementSurface = 'home_banner' | 'modal' | 'inbox' | 'tooltip';
export type AnnouncementImportance = 'low' | 'medium' | 'high';
export type AnnouncementActionType = 'none' | 'open_link' | 'open_screen' | 'open_tool';
export type AnnouncementRepeatMode = 'once' | 'per_app_open' | 'interval_hours';
export type SurveyCategory = 'survey' | 'user_insights';

// Response action - what to do when user selects specific answer
export interface ResponseAction {
  triggerValue: string; // The answer value that triggers this action
  actionType: 'show_modal' | 'open_link' | 'open_screen' | 'none';
  actionValue?: string; // Modal message, URL, or screen name
  actionTitle?: string; // Title for modal
}

export interface SurveyQuestion {
  id: string;
  type: 'single_choice' | 'multiple_choice' | 'text' | 'number' | 'yes_no' | 'rating' | 'email' | 'date' | 'dropdown';
  question: string;
  description?: string; // Help text shown below question
  options?: string[];
  required?: boolean;
  placeholder?: string;
  min?: number;
  max?: number;
  // Rating specific
  ratingScale?: 5 | 10; // 1-5 or 1-10
  ratingLabels?: { low: string; high: string }; // e.g., "Poor" to "Excellent"
  // Text specific
  multiline?: boolean;
  maxLength?: number;
  // Validation
  validation?: 'none' | 'email' | 'phone' | 'url';
  // User Insights - link answer to user profile field
  linkToUserProfile?: string; // e.g., 'profession', 'specialty', 'country'
  // Response actions
  responseActions?: ResponseAction[];
  // Images - optional array of image URLs to display with the question (carousel if multiple)
  images?: string[];
}

// Dismissible mode: yes (always), no (never), remind_later (show again after interval)
export type DismissibleMode = 'yes' | 'no' | 'remind_later';

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
  dismissible_mode: DismissibleMode; // New: yes, no, or remind_later
  remind_later_count: number; // How many times to show "remind later"
  remind_later_sessions: number; // Sessions between reminders
  // Basic Targeting
  target_country: string;
  target_city: string;
  target_speciality: string;
  target_min_app_version: string;
  target_max_app_version: string;
  target_logged_in_only: boolean;
  target_anonymous_only: boolean;
  // User Insights Targeting
  target_degree: string;
  target_subspecialty: string;
  target_profession: string;
  target_hospital: string;
  target_years_experience: string;
  // Device/Platform Targeting
  target_platform: string;
  target_is_real_device: boolean | null;
  target_device_brand: string;
  target_ip_addresses: string;
  thumbnail: string;
  image_url: string;
  background_color: string;
  text_color: string;
  questions: SurveyQuestion[];
  // Survey specific
  survey_category?: SurveyCategory;
  survey_badge_text?: string; // Custom badge text like "Survey", "Quiz", "Question"
}

const DEFAULT_FORM: AnnouncementFormData = {
  title: '', message: '', kind: 'announcement', surface: 'home_banner', importance: 'medium',
  action_type: 'none', action_value: '', cta_label: '',
  start_at: new Date().toISOString().slice(0, 16), end_at: '', is_active: true,
  repeat_mode: 'once', repeat_interval_hours: 24, max_times_seen_per_user: 1, dismissible: true,
  dismissible_mode: 'yes', remind_later_count: 3, remind_later_sessions: 1,
  // Basic Targeting
  target_country: '', target_city: '', target_speciality: '', 
  target_min_app_version: '', target_max_app_version: '',
  target_logged_in_only: false, target_anonymous_only: false,
  // User Insights Targeting
  target_degree: '', target_subspecialty: '', target_profession: '',
  target_hospital: '', target_years_experience: '',
  // Device/Platform Targeting
  target_platform: '', target_is_real_device: null, target_device_brand: '', target_ip_addresses: '',
  thumbnail: '', image_url: '', background_color: '', text_color: '', questions: [],
  survey_category: 'survey', survey_badge_text: 'Survey',
};

// User profile fields that can be linked to survey answers
const USER_PROFILE_FIELDS = [
  { value: '', label: 'None (don\'t link)' },
  { value: 'profession', label: 'Profession' },
  { value: 'specialty', label: 'Specialty' },
  { value: 'subspecialty', label: 'Subspecialty' },
  { value: 'degree', label: 'Degree' },
  { value: 'country', label: 'Country' },
  { value: 'city', label: 'City' },
  { value: 'hospital', label: 'Hospital/Workplace' },
  { value: 'years_experience', label: 'Years of Experience' },
];

interface Props {
  initialData?: Partial<AnnouncementFormData>;
  onSubmit: (data: AnnouncementFormData) => Promise<void>;
  onCancel: () => void;
  isEditing?: boolean;
}

// Preview Components
function BannerPreview({ form }: { form: AnnouncementFormData }) {
  const isSurvey = form.kind === 'survey';
  const importanceColors = {
    high: '#EF4444',
    medium: '#F59E0B', 
    low: '#6366F1',
  };
  const borderColor = isSurvey ? '#8B5CF6' : importanceColors[form.importance];

  return (
    <div className="bg-gray-100 rounded-lg p-3 text-xs">
      <div className="text-gray-600 mb-2 text-center">🏠 Home Banner</div>
      <div 
        className="bg-white rounded-lg border-l-4 p-3 shadow-sm"
        style={{ borderLeftColor: borderColor }}
      >
        <div className="flex items-start gap-2">
          <div className="flex-1">
            {isSurvey && (
              <div className="inline-flex items-center gap-1 bg-purple-100 text-purple-700 px-2 py-1 rounded text-xs mb-2">
                📋 {form.survey_badge_text || 'Survey'}
              </div>
            )}
            <div className="font-semibold text-gray-900 text-sm mb-1">
              {form.title || 'Announcement Title'}
            </div>
            {form.message && (
              <div className="text-gray-600 text-xs mb-2">{form.message}</div>
            )}
            {(form.cta_label || form.action_type !== 'none' || isSurvey) && (
              <div 
                className="inline-flex items-center gap-1 px-3 py-1 rounded text-xs text-white"
                style={{ backgroundColor: borderColor }}
              >
                {form.cta_label || (isSurvey ? 'Take Survey' : 'Learn More')}
                <span>→</span>
              </div>
            )}
          </div>
          {form.thumbnail && (
            <img src={form.thumbnail} alt="" className="w-12 h-12 rounded object-cover" />
          )}
        </div>
      </div>
    </div>
  );
}

function ModalPreview({ form }: { form: AnnouncementFormData }) {
  const isSurvey = form.kind === 'survey';
  const importanceColors = {
    high: '#EF4444',
    medium: '#F59E0B', 
    low: '#6366F1',
  };
  const accentColor = isSurvey ? '#8B5CF6' : importanceColors[form.importance];

  return (
    <div className="bg-gray-100 rounded-lg p-3 text-xs">
      <div className="text-gray-600 mb-2 text-center">📱 Modal</div>
      <div className="bg-black/60 rounded-lg p-2">
        <div className="bg-white rounded-lg p-3 max-w-xs mx-auto relative">
          {form.dismissible_mode === 'yes' && (
            <div className="absolute top-2 right-2 w-4 h-4 bg-gray-200 rounded-full flex items-center justify-center text-xs">×</div>
          )}
          
          {form.thumbnail && (
            <div className="bg-gray-100 rounded p-2 mb-3">
              <img src={form.thumbnail} alt="" className="w-full h-16 object-contain" />
            </div>
          )}
          
          {isSurvey && (
            <div className="inline-flex items-center gap-1 bg-purple-100 text-purple-700 px-2 py-1 rounded text-xs mb-2">
              📋 {form.survey_badge_text || 'Survey'}
            </div>
          )}
          
          <div className="font-bold text-gray-900 text-sm mb-2">
            {form.title || 'Announcement Title'}
          </div>
          
          {form.message && (
            <div className="text-gray-600 text-xs mb-3">{form.message}</div>
          )}
          
          {(form.action_type !== 'none' || isSurvey) && (
            <button 
              className="w-full py-2 px-3 rounded text-xs text-white font-medium"
              style={{ backgroundColor: accentColor }}
            >
              {form.cta_label || (isSurvey ? 'Take Survey' : 'Learn More')}
            </button>
          )}
          
          {form.dismissible_mode === 'remind_later' && (
            <button className="w-full mt-2 py-1 text-xs text-gray-500">
              Remind Me Later
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

function InboxPreview({ form }: { form: AnnouncementFormData }) {
  const isSurvey = form.kind === 'survey';
  const importanceColors = {
    high: '#EF4444',
    medium: '#F59E0B', 
    low: '#6366F1',
  };
  const accentColor = isSurvey ? '#8B5CF6' : importanceColors[form.importance];

  return (
    <div className="bg-gray-100 rounded-lg p-3 text-xs">
      <div className="text-gray-600 mb-2 text-center">📬 Inbox</div>
      <div 
        className="bg-white rounded-lg border-l-4 p-3 shadow-sm relative"
        style={{ borderLeftColor: accentColor }}
      >
        {/* Unread indicator */}
        <div className="absolute top-2 right-2 w-2 h-2 bg-blue-500 rounded-full"></div>
        
        <div className="flex items-start gap-2">
          {form.thumbnail && (
            <img src={form.thumbnail} alt="" className="w-10 h-10 rounded object-cover" />
          )}
          <div className="flex-1">
            {isSurvey && (
              <div className="inline-flex items-center gap-1 bg-purple-100 text-purple-700 px-2 py-1 rounded text-xs mb-1">
                📋 {form.survey_badge_text || 'Survey'}
              </div>
            )}
            <div className="font-semibold text-gray-900 text-sm">
              {form.title || 'Announcement Title'}
            </div>
            {form.message && (
              <div className="text-gray-600 text-xs mt-1">{form.message}</div>
            )}
            <div className="text-gray-400 text-xs mt-1">
              {new Date().toLocaleDateString()}
            </div>
            {(form.cta_label || form.action_type !== 'none' || isSurvey) && (
              <div 
                className="inline-flex items-center gap-1 px-2 py-1 rounded text-xs text-white mt-2"
                style={{ backgroundColor: accentColor }}
              >
                {form.cta_label || (isSurvey ? 'Take Survey' : 'Learn More')}
                <span>→</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function AnnouncementForm({ initialData, onSubmit, onCancel, isEditing }: Props) {
  const [form, setForm] = useState<AnnouncementFormData>(() => ({ ...DEFAULT_FORM, ...initialData }));
  const [activeTab, setActiveTab] = useState<string>('settings');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Reset form when initialData changes (for editing different announcements)
  useEffect(() => {
    if (initialData) {
      setForm({ ...DEFAULT_FORM, ...initialData });
    }
  }, [(initialData as any)?.id]); // Only reset when editing a different announcement

  const updateField = <K extends keyof AnnouncementFormData>(key: K, value: AnnouncementFormData[K]) => {
    setForm(prev => ({ ...prev, [key]: value }));
  };

  const handleSubmit = async () => {
    if (!form.title.trim()) { setError('Title is required'); return; }
    if (form.kind === 'survey' && form.questions.length === 0) { setError('Survey must have at least one question'); return; }
    setSaving(true); setError(null);
    try { await onSubmit(form); } catch (err: any) { setError(err.message || 'Failed to save'); } finally { setSaving(false); }
  };

  const addQuestion = (type: SurveyQuestion['type'] = 'single_choice') => {
    const defaults: Record<SurveyQuestion['type'], Partial<SurveyQuestion>> = {
      single_choice: { options: ['Option 1', 'Option 2'] },
      multiple_choice: { options: ['Option 1', 'Option 2', 'Option 3'] },
      dropdown: { options: ['Option 1', 'Option 2', 'Option 3'] },
      rating: { ratingScale: 5, ratingLabels: { low: 'Poor', high: 'Excellent' } },
      text: { multiline: false, maxLength: 500 },
      number: { min: 0, max: 100 },
      yes_no: {},
      email: { validation: 'email' },
      date: {},
    };
    const newQ: SurveyQuestion = { 
      id: `q_${Date.now()}`, 
      type, 
      question: '', 
      required: true,
      ...defaults[type]
    };
    updateField('questions', [...form.questions, newQ]);
  };

  const updateQuestion = (idx: number, updates: Partial<SurveyQuestion>) => {
    const newQ = [...form.questions]; 
    newQ[idx] = { ...newQ[idx], ...updates }; 
    updateField('questions', newQ);
  };

  const removeQuestion = (idx: number) => updateField('questions', form.questions.filter((_, i) => i !== idx));

  const duplicateQuestion = (idx: number) => {
    const original = form.questions[idx];
    const duplicate: SurveyQuestion = { ...original, id: `q_${Date.now()}`, question: `${original.question} (copy)` };
    const newQuestions = [...form.questions];
    newQuestions.splice(idx + 1, 0, duplicate);
    updateField('questions', newQuestions);
  };

  const moveQuestion = (idx: number, direction: 'up' | 'down') => {
    const newIdx = direction === 'up' ? idx - 1 : idx + 1;
    if (newIdx < 0 || newIdx >= form.questions.length) return;
    const newQuestions = [...form.questions];
    [newQuestions[idx], newQuestions[newIdx]] = [newQuestions[newIdx], newQuestions[idx]];
    updateField('questions', newQuestions);
  };

  const getQuestionTypeIcon = (type: SurveyQuestion['type']) => {
    const icons: Record<SurveyQuestion['type'], string> = {
      single_choice: '⭕', multiple_choice: '☑️', yes_no: '✅', text: '📝', 
      number: '🔢', rating: '⭐', email: '📧', date: '📅', dropdown: '📋'
    };
    return icons[type] || '❓';
  };

  const getQuestionTypeLabel = (type: SurveyQuestion['type']) => {
    const labels: Record<SurveyQuestion['type'], string> = {
      single_choice: 'Single Choice', multiple_choice: 'Multiple Choice', yes_no: 'Yes/No',
      text: 'Text Input', number: 'Number', rating: 'Rating Scale', 
      email: 'Email', date: 'Date', dropdown: 'Dropdown'
    };
    return labels[type] || type;
  };

  const tabs = [
    { id: 'settings', label: '⚙️ Settings' },
    ...(form.kind === 'survey' ? [{ id: 'questions', label: `❓ Questions (${form.questions.length})` }] : []),
  ];

  return (
    <div className="grid grid-cols-12 gap-6">
      {/* Form Panel - Left Side */}
      <div className="col-span-8 bg-slate-900 rounded-2xl border border-white/10 overflow-hidden">
        {/* Tabs - only show if survey */}
        {form.kind === 'survey' && (
          <div className="flex border-b border-white/10 bg-slate-800/50">
            {tabs.map(tab => (
              <button key={tab.id} onClick={() => setActiveTab(tab.id)}
                className={`px-6 py-3 text-sm font-medium ${activeTab === tab.id ? 'border-b-2 border-indigo-500 text-indigo-300' : 'text-slate-400 hover:text-slate-300'}`}>
                {tab.label}
              </button>
            ))}
          </div>
        )}

        {error && <div className="mx-4 mt-4 bg-rose-500/20 border border-rose-500/50 rounded-lg px-4 py-2 text-rose-200 text-sm">{error}</div>}

        <div className="p-4 max-h-[70vh] overflow-y-auto">
        {activeTab === 'settings' && (
          <div className="space-y-4">
            {/* Row 1: Type + Title + Message */}
            <div className="grid grid-cols-12 gap-3">
              <div className="col-span-2">
                <Label>Type</Label>
                <div className="flex gap-1">
                  {(['announcement', 'survey'] as const).map(k => (
                    <button key={k} onClick={() => updateField('kind', k)}
                      className={`flex-1 px-2 py-1.5 rounded text-xs font-medium ${form.kind === k ? 'bg-indigo-500 text-white' : 'bg-slate-700 text-slate-300'}`}>
                      {k === 'announcement' ? '📢' : '📋'}
                    </button>
                  ))}
                </div>
              </div>
              <div className="col-span-4">
                <Label>Title *</Label>
                <input type="text" value={form.title} onChange={e => updateField('title', e.target.value)} maxLength={100}
                  placeholder="New Feature: Dark Mode" className="input-sm" />
              </div>
              <div className="col-span-6">
                <Label>Message</Label>
                <input type="text" value={form.message} onChange={e => updateField('message', e.target.value)} maxLength={300}
                  placeholder="Description text..." className="input-sm" />
              </div>
            </div>

            {/* Survey-specific settings */}
            {form.kind === 'survey' && (
              <div className="grid grid-cols-12 gap-3 bg-purple-500/10 border border-purple-500/20 rounded-lg p-3">
                <div className="col-span-3">
                  <Label>📋 Category</Label>
                  <select value={form.survey_category || 'survey'} onChange={e => updateField('survey_category', e.target.value as SurveyCategory)} className="input-sm">
                    <option value="survey">📊 Survey / Quiz</option>
                    <option value="user_insights">👤 User Insights</option>
                  </select>
                </div>
                <div className="col-span-3">
                  <Label>Badge Text</Label>
                  <input type="text" value={form.survey_badge_text ?? ''} onChange={e => updateField('survey_badge_text', e.target.value)} maxLength={20}
                    placeholder="Survey" className="input-sm" />
                </div>
                <div className="col-span-3">
                  <Label>CTA Button Text</Label>
                  <input type="text" value={form.cta_label || ''} onChange={e => updateField('cta_label', e.target.value)} maxLength={30}
                    placeholder="Take Survey" className="input-sm" />
                </div>
                <div className="col-span-3 flex items-end">
                  <div className="text-xs text-purple-300/70">
                    {form.survey_category === 'user_insights' && '👤 Linked to user profile'}
                    {form.survey_category === 'survey' && '📊 Anonymous responses'}
                  </div>
                </div>
              </div>
            )}

            {/* Row 2: Surface + Importance + Active + Dismissible */}
            <div className="grid grid-cols-12 gap-3">
              <div className="col-span-3">
                <Label>Surface</Label>
                <select value={form.surface} onChange={e => updateField('surface', e.target.value as AnnouncementSurface)} className="input-sm">
                  <option value="home_banner">🏠 Home Banner</option>
                  <option value="modal">📱 Modal</option>
                  <option value="inbox">📬 Inbox Only</option>
                </select>
              </div>
              <div className="col-span-3">
                <Label>Importance</Label>
                <select value={form.importance} onChange={e => updateField('importance', e.target.value as AnnouncementImportance)} className="input-sm">
                  <option value="high">🔴 High</option>
                  <option value="medium">🟡 Medium</option>
                  <option value="low">🔵 Low</option>
                </select>
              </div>
              <div className="col-span-3">
                <Label>Status</Label>
                <button onClick={() => updateField('is_active', !form.is_active)}
                  className={`w-full px-3 py-1.5 rounded text-xs font-medium ${form.is_active ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/50' : 'bg-slate-700 text-slate-400'}`}>
                  {form.is_active ? '✅ Active' : '⏸️ Draft'}
                </button>
              </div>
              <div className="col-span-3">
                <Label>Dismissible</Label>
                <select 
                  value={form.dismissible_mode || 'yes'} 
                  onChange={e => {
                    const mode = e.target.value as DismissibleMode;
                    updateField('dismissible_mode', mode);
                    updateField('dismissible', mode !== 'no');
                  }} 
                  className="input-sm"
                >
                  <option value="yes">✓ Yes</option>
                  <option value="no">✗ No</option>
                  <option value="remind_later">⏰ Remind Later</option>
                </select>
              </div>
            </div>

            {/* Remind Later Options - only show when remind_later is selected */}
            {form.dismissible_mode === 'remind_later' && (
              <div className="grid grid-cols-12 gap-3 bg-amber-500/10 border border-amber-500/20 rounded-lg p-3">
                <div className="col-span-4">
                  <Label>⏰ Remind Count</Label>
                  <input 
                    type="number" 
                    value={form.remind_later_count || 3} 
                    onChange={e => updateField('remind_later_count', parseInt(e.target.value) || 1)} 
                    min={1} 
                    max={10}
                    className="input-sm" 
                  />
                  <div className="text-xs text-amber-300/70 mt-1">Times to show again</div>
                </div>
                <div className="col-span-4">
                  <Label>📱 Session Interval</Label>
                  <input 
                    type="number" 
                    value={form.remind_later_sessions || 1} 
                    onChange={e => updateField('remind_later_sessions', parseInt(e.target.value) || 1)} 
                    min={1} 
                    max={30}
                    className="input-sm" 
                  />
                  <div className="text-xs text-amber-300/70 mt-1">App sessions between</div>
                </div>
                <div className="col-span-4 flex items-center">
                  <div className="text-xs text-amber-300/70">
                    User can dismiss but will see it again after {form.remind_later_sessions || 1} session(s), up to {form.remind_later_count || 3} times
                  </div>
                </div>
              </div>
            )}

            {/* Safety Warning for non-dismissible without action */}
            {form.dismissible_mode === 'no' && form.action_type === 'none' && (
              <div className="bg-rose-500/20 border border-rose-500/50 rounded-lg p-3 text-rose-200 text-xs">
                ⚠️ <strong>Safety Warning:</strong> Non-dismissible announcements without a CTA action will automatically have a dismiss button added to prevent users from being stuck.
              </div>
            )}

            {/* Row 3: Action Type + Action Value + CTA Label */}
            <div className="grid grid-cols-12 gap-3">
              <div className="col-span-3">
                <Label>Action</Label>
                <select value={form.action_type} onChange={e => updateField('action_type', e.target.value as AnnouncementActionType)} className="input-sm">
                  <option value="none">None</option>
                  <option value="open_link">🔗 Open Link</option>
                  <option value="open_screen">📱 Open Screen</option>
                  <option value="open_tool">🔧 Open Tool</option>
                </select>
              </div>
              <div className="col-span-6">
                <Label>Action Value</Label>
                {form.action_type === 'open_link' && (
                  <input type="url" value={form.action_value} onChange={e => updateField('action_value', e.target.value)}
                    placeholder="https://example.com" className="input-sm" />
                )}
                {form.action_type === 'open_screen' && (
                  <select value={form.action_value} onChange={e => updateField('action_value', e.target.value)} className="input-sm">
                    <option value="">-- Select --</option>
                    <optgroup label="Main">
                      <option value="Home">🏠 Home</option>
                      <option value="VisionTools">👁️ Vision Tools</option>
                      <option value="DecisionSupport">🧠 Decision Support</option>
                      <option value="More">⋯ More</option>
                    </optgroup>
                    <optgroup label="Account">
                      <option value="Login">🔐 Login / Sign In</option>
                      <option value="Profile">👤 Profile</option>
                      <option value="Settings">⚙️ Settings</option>
                    </optgroup>
                    <optgroup label="Other">
                      <option value="AnnouncementInbox">📬 Announcements</option>
                      <option value="Calibration">📏 Calibration</option>
                      <option value="Feedback">💬 Feedback</option>
                    </optgroup>
                  </select>
                )}
                {form.action_type === 'open_tool' && (
                  <select value={form.action_value} onChange={e => updateField('action_value', e.target.value)} className="input-sm">
                    <option value="">-- Select Tool --</option>
                    {/* DECISION SUPPORT TOOLS */}
                    <optgroup label="📊 Pediatrics (Decision Support)">
                      <option value="pediatric-glasses">Pediatric Glasses</option>
                      <option value="amblyopia-treatment">Amblyopia Treatment</option>
                      <option value="pediatric-iol">Pediatric IOL Advisor</option>
                    </optgroup>
                    <optgroup label="📊 Strabismus (Decision Support)">
                      <option value="strabismus-surgery-dose">Strabismus Surgery Dose</option>
                      <option value="parks-3-step-test">Parks 3-Step Test</option>
                      <option value="prism-summation">Prism Summation</option>
                      <option value="prismatic-effect-glasses">Prismatic Effect (Glasses)</option>
                      <option value="kestenbaum-planner">Kestenbaum Planner</option>
                    </optgroup>
                    <optgroup label="📊 Optometry (Decision Support)">
                      <option value="va-notation">Visual Acuity Conversion</option>
                      <option value="retinoscopy-to-rx">Retinoscopy to Rx</option>
                      <option value="spectacle-to-cl">Spectacle to CL</option>
                      <option value="near-add-estimator">Near Add Estimator</option>
                    </optgroup>
                    <optgroup label="📊 Glaucoma (Decision Support)">
                      <option value="iop-correction">IOP Correction</option>
                      <option value="corneal-diameter">Corneal Diameter Chart</option>
                      <option value="schiotz">Schiotz Converter</option>
                    </optgroup>
                    <optgroup label="📊 Anterior Segment (Decision Support)">
                      <option value="iol-calculator">PCIOL Calculator</option>
                      <option value="lasik-ectasia-risk">LASIK Ectasia Risk</option>
                    </optgroup>
                    {/* VISION TOOLS */}
                    <optgroup label="👁️ Vision Tests">
                      <option value="e-chart-vision-test">E Chart Vision Test</option>
                      <option value="logmar-chart">LogMAR Chart</option>
                      <option value="numbers-chart">Numbers Chart</option>
                      <option value="landolt-c-chart">Landolt C Chart</option>
                      <option value="arabic-va-chart">Arabic VA Chart</option>
                      <option value="near-english-chart">Near Chart (English)</option>
                      <option value="near-arabic-chart">Near Chart (Arabic)</option>
                      <option value="near-numbers-chart">Near Chart (Numbers)</option>
                      <option value="astigmatic-fan">Astigmatic Fan</option>
                    </optgroup>
                    <optgroup label="👁️ Contrast Sensitivity">
                      <option value="contrast-e-chart">Contrast Test (E Chart)</option>
                      <option value="contrast-logmar">Contrast Test (LogMAR)</option>
                      <option value="contrast-numbers">Contrast Test (Numbers)</option>
                      <option value="contrast-landolt-c">Contrast Test (Landolt C)</option>
                      <option value="contrast-arabic">Contrast Test (Arabic)</option>
                      <option value="contrast-kids-shapes">Contrast Test (Kids Shapes)</option>
                    </optgroup>
                    <optgroup label="👁️ Pediatric Tools (Vision)">
                      <option value="kids-fixation-target">Kids Fixation Target</option>
                      <option value="shaped-vision-chart">Shaped Vision Chart</option>
                      <option value="optokinetic-drum">OptoKinetic Drum</option>
                    </optgroup>
                    <optgroup label="👁️ Strabismus Tools (Vision)">
                      <option value="worth-4-dots-test">Worth 4 Dots Test</option>
                      <option value="light-target">Light Target</option>
                      <option value="nine-gaze-camera">9 Gaze Camera</option>
                    </optgroup>
                    <optgroup label="👁️ Retina">
                      <option value="amsler-grid">Amsler Grid</option>
                    </optgroup>
                  </select>
                )}
                {form.action_type === 'none' && (
                  <input type="text" disabled placeholder="No action" className="input-sm opacity-50" />
                )}
              </div>
              <div className="col-span-3">
                <Label>CTA Label</Label>
                <input type="text" value={form.cta_label} onChange={e => updateField('cta_label', e.target.value)} maxLength={20}
                  placeholder="Learn More" className="input-sm" />
              </div>
            </div>

            {/* Row 4: Schedule */}
            <div className="grid grid-cols-12 gap-3">
              <div className="col-span-2">
                <Label>Start Date *</Label>
                <input 
                  type="date" 
                  value={form.start_at ? form.start_at.split('T')[0] : ''} 
                  onChange={e => {
                    const time = form.start_at ? form.start_at.split('T')[1] || '00:00' : '00:00';
                    updateField('start_at', e.target.value ? `${e.target.value}T${time}` : '');
                  }} 
                  className="input-sm" 
                />
              </div>
              <div className="col-span-2">
                <Label>Start Time</Label>
                <input 
                  type="time" 
                  value={form.start_at ? form.start_at.split('T')[1] || '00:00' : '00:00'} 
                  onChange={e => {
                    const date = form.start_at ? form.start_at.split('T')[0] : new Date().toISOString().split('T')[0];
                    updateField('start_at', `${date}T${e.target.value}`);
                  }} 
                  className="input-sm" 
                />
              </div>
              <div className="col-span-2">
                <Label>End Date</Label>
                <input 
                  type="date" 
                  value={form.end_at ? form.end_at.split('T')[0] : ''} 
                  onChange={e => {
                    const time = form.end_at ? form.end_at.split('T')[1] || '23:59' : '23:59';
                    updateField('end_at', e.target.value ? `${e.target.value}T${time}` : '');
                  }} 
                  className="input-sm" 
                />
              </div>
              <div className="col-span-2">
                <Label>End Time</Label>
                <input 
                  type="time" 
                  value={form.end_at ? form.end_at.split('T')[1] || '23:59' : ''} 
                  onChange={e => {
                    if (form.end_at) {
                      const date = form.end_at.split('T')[0];
                      updateField('end_at', `${date}T${e.target.value}`);
                    }
                  }} 
                  className="input-sm" 
                  disabled={!form.end_at}
                />
              </div>
              <div className="col-span-4">
                <Label>Thumbnail URL</Label>
                <input type="url" value={form.thumbnail} onChange={e => updateField('thumbnail', e.target.value)}
                  placeholder="https://..." className="input-sm" />
              </div>
            </div>

            {/* Row 5: Repeat Mode */}
            <div className="grid grid-cols-12 gap-3">
              <div className="col-span-4">
                <Label>Repeat Mode</Label>
                <select value={form.repeat_mode} onChange={e => updateField('repeat_mode', e.target.value as AnnouncementRepeatMode)} className="input-sm">
                  <option value="once">🎯 Once (show only once ever)</option>
                  <option value="per_app_open">🔄 Per App Open (once per session)</option>
                  <option value="interval_hours">⏰ Interval (every X hours)</option>
                </select>
              </div>
              {form.repeat_mode === 'interval_hours' && (
                <div className="col-span-4">
                  <Label>Interval (Hours)</Label>
                  <input type="number" value={form.repeat_interval_hours} onChange={e => updateField('repeat_interval_hours', parseInt(e.target.value) || 24)} min={1} className="input-sm" />
                </div>
              )}
              {form.repeat_mode !== 'once' && (
                <div className="col-span-4">
                  <Label>Max Views (0=∞)</Label>
                  <input type="number" value={form.max_times_seen_per_user} onChange={e => updateField('max_times_seen_per_user', parseInt(e.target.value) || 0)} min={0} className="input-sm" />
                </div>
              )}
            </div>

            {/* Row 6: Targeting */}
            <div className="border-t border-white/10 pt-4 mt-2">
              <div className="text-xs font-medium text-slate-400 mb-3">🎯 Targeting (optional) - Leave empty to show to all users</div>
              
              {/* Location & User Type Targeting */}
              <div className="grid grid-cols-12 gap-3 mb-3">
                <div className="col-span-3">
                  <Label>🌍 Country (ISO codes)</Label>
                  <input type="text" value={form.target_country} onChange={e => updateField('target_country', e.target.value.toUpperCase())}
                    placeholder="US, SA, EG" className="input-sm" />
                  <div className="text-xs text-slate-500 mt-1">Comma-separated</div>
                </div>
                <div className="col-span-3">
                  <Label>🏙️ City</Label>
                  <input type="text" value={form.target_city || ''} onChange={e => updateField('target_city', e.target.value)}
                    placeholder="Cairo, Riyadh" className="input-sm" />
                  <div className="text-xs text-slate-500 mt-1">Comma-separated</div>
                </div>
                <div className="col-span-3">
                  <Label>👤 Users</Label>
                  <select value={form.target_logged_in_only ? 'logged_in' : form.target_anonymous_only ? 'anonymous' : 'all'}
                    onChange={e => {
                      updateField('target_logged_in_only', e.target.value === 'logged_in');
                      updateField('target_anonymous_only', e.target.value === 'anonymous');
                    }} className="input-sm">
                    <option value="all">All Users</option>
                    <option value="logged_in">Logged In Only</option>
                    <option value="anonymous">Anonymous Only</option>
                  </select>
                </div>
                <div className="col-span-3">
                  <Label>📱 Platform</Label>
                  <select value={form.target_platform || ''} onChange={e => updateField('target_platform', e.target.value)} className="input-sm">
                    <option value="">All Platforms</option>
                    <option value="ios">iOS Only</option>
                    <option value="android">Android Only</option>
                  </select>
                </div>
              </div>

              {/* User Insights Targeting */}
              <div className="bg-purple-500/10 border border-purple-500/20 rounded-lg p-3 mb-3">
                <div className="text-xs font-medium text-purple-300 mb-2">👤 User Insights Targeting (from survey responses)</div>
                <div className="grid grid-cols-12 gap-3">
                  <div className="col-span-3">
                    <Label>Profession</Label>
                    <select value={form.target_profession || ''} onChange={e => updateField('target_profession', e.target.value)} className="input-sm">
                      <option value="">All Professions</option>
                      <option value="Doctor">Doctor</option>
                      <option value="Resident">Resident</option>
                      <option value="Medical Student">Medical Student</option>
                      <option value="Optometrist">Optometrist</option>
                      <option value="Nurse">Nurse</option>
                      <option value="Other">Other</option>
                    </select>
                  </div>
                  <div className="col-span-3">
                    <Label>Specialty</Label>
                    <input type="text" value={form.target_speciality || ''} onChange={e => updateField('target_speciality', e.target.value)}
                      placeholder="Ophthalmology" className="input-sm" />
                  </div>
                  <div className="col-span-3">
                    <Label>Subspecialty</Label>
                    <input type="text" value={form.target_subspecialty || ''} onChange={e => updateField('target_subspecialty', e.target.value)}
                      placeholder="Retina, Glaucoma" className="input-sm" />
                    <div className="text-xs text-slate-500 mt-1">Comma-separated</div>
                  </div>
                  <div className="col-span-3">
                    <Label>Degree</Label>
                    <input type="text" value={form.target_degree || ''} onChange={e => updateField('target_degree', e.target.value)}
                      placeholder="MD, MBBS, PhD" className="input-sm" />
                    <div className="text-xs text-slate-500 mt-1">Comma-separated</div>
                  </div>
                </div>
              </div>

              {/* Device & Version Targeting */}
              <div className="bg-slate-800/50 border border-white/5 rounded-lg p-3 mb-3">
                <div className="text-xs font-medium text-slate-400 mb-2">📱 Device & Version Targeting</div>
                <div className="grid grid-cols-12 gap-3">
                  <div className="col-span-2">
                    <Label>Min Version</Label>
                    <input type="text" value={form.target_min_app_version} onChange={e => updateField('target_min_app_version', e.target.value)}
                      placeholder="2.0.0" className="input-sm" />
                  </div>
                  <div className="col-span-2">
                    <Label>Max Version</Label>
                    <input type="text" value={form.target_max_app_version} onChange={e => updateField('target_max_app_version', e.target.value)}
                      placeholder="2.9.9" className="input-sm" />
                  </div>
                  <div className="col-span-2">
                    <Label>Device Type</Label>
                    <select value={form.target_is_real_device === null ? '' : form.target_is_real_device ? 'real' : 'emulator'} 
                      onChange={e => updateField('target_is_real_device', e.target.value === '' ? null : e.target.value === 'real')} className="input-sm">
                      <option value="">All Devices</option>
                      <option value="real">Real Devices Only</option>
                      <option value="emulator">Emulators Only</option>
                    </select>
                  </div>
                  <div className="col-span-3">
                    <Label>Device Brand</Label>
                    <input type="text" value={form.target_device_brand || ''} onChange={e => updateField('target_device_brand', e.target.value)}
                      placeholder="Apple, Samsung" className="input-sm" />
                    <div className="text-xs text-slate-500 mt-1">Comma-separated</div>
                  </div>
                  <div className="col-span-3">
                    <Label>🧪 Test IPs</Label>
                    <input type="text" value={form.target_ip_addresses || ''} onChange={e => updateField('target_ip_addresses', e.target.value)}
                      placeholder="192.168.1.1" className="input-sm" />
                    <div className="text-xs text-amber-400 mt-1">For testing only</div>
                  </div>
                </div>
              </div>

              {/* Targeting Summary */}
              {(form.target_country || form.target_city || form.target_platform || form.target_profession || 
                form.target_speciality || form.target_degree || form.target_ip_addresses) && (
                <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-lg p-2 text-xs text-emerald-300">
                  <span className="font-medium">Active Filters:</span>{' '}
                  {form.target_country && <span className="bg-emerald-500/20 px-1 rounded mr-1">Country: {form.target_country}</span>}
                  {form.target_city && <span className="bg-emerald-500/20 px-1 rounded mr-1">City: {form.target_city}</span>}
                  {form.target_platform && <span className="bg-emerald-500/20 px-1 rounded mr-1">Platform: {form.target_platform}</span>}
                  {form.target_profession && <span className="bg-emerald-500/20 px-1 rounded mr-1">Profession: {form.target_profession}</span>}
                  {form.target_speciality && <span className="bg-emerald-500/20 px-1 rounded mr-1">Specialty: {form.target_speciality}</span>}
                  {form.target_degree && <span className="bg-emerald-500/20 px-1 rounded mr-1">Degree: {form.target_degree}</span>}
                  {form.target_ip_addresses && <span className="bg-amber-500/20 px-1 rounded mr-1">🧪 Test IPs</span>}
                </div>
              )}
            </div>
          </div>
        )}


        {/* Questions Tab - Only for Surveys */}
        {activeTab === 'questions' && form.kind === 'survey' && (
          <div className="space-y-4">
            {/* Header with Add Question dropdown */}
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-400">{form.questions.length} question{form.questions.length !== 1 ? 's' : ''}</span>
              <div className="relative group">
                <button className="bg-indigo-500 hover:bg-indigo-600 text-white px-3 py-1.5 rounded text-sm font-medium flex items-center gap-1">
                  + Add Question <span className="text-xs">▼</span>
                </button>
                <div className="absolute right-0 top-full mt-1 bg-slate-800 border border-white/10 rounded-lg shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50 min-w-[180px]">
                  {(['single_choice', 'multiple_choice', 'dropdown', 'yes_no', 'text', 'number', 'rating', 'email', 'date'] as const).map(type => (
                    <button key={type} onClick={() => addQuestion(type)}
                      className="w-full px-3 py-2 text-left text-xs text-slate-300 hover:bg-slate-700 flex items-center gap-2">
                      <span>{getQuestionTypeIcon(type)}</span>
                      <span>{getQuestionTypeLabel(type)}</span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
            
            {form.questions.length === 0 && (
              <div className="text-center py-12 text-slate-500 border-2 border-dashed border-slate-700 rounded-lg">
                <div className="text-3xl mb-2">📋</div>
                <div className="text-sm">No questions yet</div>
                <div className="text-xs mt-1">Hover over "Add Question" to select a type</div>
              </div>
            )}
            
            {form.questions.map((q, idx) => (
              <div key={q.id} className="bg-slate-800/50 border border-white/10 rounded-lg overflow-hidden">
                {/* Question Header */}
                <div className="flex items-center justify-between px-3 py-2 bg-slate-800/80 border-b border-white/5">
                  <div className="flex items-center gap-2">
                    <span className="text-lg">{getQuestionTypeIcon(q.type)}</span>
                    <span className="text-xs font-medium text-indigo-300">Q{idx + 1}</span>
                    <span className="text-xs text-slate-500">•</span>
                    <span className="text-xs text-slate-400">{getQuestionTypeLabel(q.type)}</span>
                    {q.required && <span className="text-xs text-rose-400">*</span>}
                  </div>
                  <div className="flex items-center gap-1">
                    <button onClick={() => moveQuestion(idx, 'up')} disabled={idx === 0}
                      className="p-1 text-slate-400 hover:text-white disabled:opacity-30" title="Move up">↑</button>
                    <button onClick={() => moveQuestion(idx, 'down')} disabled={idx === form.questions.length - 1}
                      className="p-1 text-slate-400 hover:text-white disabled:opacity-30" title="Move down">↓</button>
                    <button onClick={() => duplicateQuestion(idx)}
                      className="p-1 text-slate-400 hover:text-indigo-300" title="Duplicate">⧉</button>
                    <button onClick={() => removeQuestion(idx)}
                      className="p-1 text-slate-400 hover:text-rose-400" title="Delete">✕</button>
                  </div>
                </div>

                {/* Question Body */}
                <div className="p-3 space-y-3">
                  {/* Question Type + Required */}
                  <div className="grid grid-cols-12 gap-2">
                    <div className="col-span-4">
                      <Label>Question Type</Label>
                      <select value={q.type} onChange={e => updateQuestion(idx, { type: e.target.value as SurveyQuestion['type'] })} className="input-sm text-xs">
                        <option value="single_choice">⭕ Single Choice</option>
                        <option value="multiple_choice">☑️ Multiple Choice</option>
                        <option value="dropdown">📋 Dropdown</option>
                        <option value="yes_no">✅ Yes / No</option>
                        <option value="text">📝 Text Input</option>
                        <option value="number">🔢 Number</option>
                        <option value="rating">⭐ Rating Scale</option>
                        <option value="email">📧 Email</option>
                        <option value="date">📅 Date</option>
                      </select>
                    </div>
                    <div className="col-span-6">
                      <Label>Question Text *</Label>
                      <input type="text" value={q.question} onChange={e => updateQuestion(idx, { question: e.target.value })}
                        placeholder="Enter your question..." className="input-sm text-xs" />
                    </div>
                    <div className="col-span-2 flex items-end pb-1">
                      <label className="flex items-center gap-1 text-xs text-slate-400 cursor-pointer">
                        <input type="checkbox" checked={q.required !== false} onChange={e => updateQuestion(idx, { required: e.target.checked })} 
                          className="w-3 h-3 rounded" />
                        Required
                      </label>
                    </div>
                  </div>

                  {/* Description/Help Text */}
                  <div>
                    <Label>Description (optional)</Label>
                    <input type="text" value={q.description || ''} onChange={e => updateQuestion(idx, { description: e.target.value })}
                      placeholder="Help text shown below the question..." className="input-sm text-xs" />
                  </div>

                  {/* Type-specific options */}
                  {/* Single/Multiple Choice & Dropdown Options */}
                  {(q.type === 'single_choice' || q.type === 'multiple_choice' || q.type === 'dropdown') && (
                    <div>
                      <Label>Options (one per line)</Label>
                      <textarea value={(q.options || []).join('\n')} 
                        onChange={e => updateQuestion(idx, { options: e.target.value.split('\n') })}
                        onBlur={e => updateQuestion(idx, { options: e.target.value.split('\n').filter(o => o.trim()) })}
                        onKeyDown={e => {
                          // Allow Enter key to create new lines
                          if (e.key === 'Enter') {
                            e.stopPropagation();
                          }
                        }}
                        rows={4} placeholder="Option 1&#10;Option 2&#10;Option 3" className="input-sm text-xs font-mono" />
                      <div className="text-xs text-slate-500 mt-1">{(q.options || []).filter(o => o.trim()).length} options</div>
                    </div>
                  )}

                  {/* Rating Scale Options */}
                  {q.type === 'rating' && (
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-3">
                        <Label>Scale</Label>
                        <select value={q.ratingScale || 5} onChange={e => updateQuestion(idx, { ratingScale: parseInt(e.target.value) as 5 | 10 })} className="input-sm text-xs">
                          <option value={5}>1-5 Stars</option>
                          <option value={10}>1-10 Scale</option>
                        </select>
                      </div>
                      <div className="col-span-4">
                        <Label>Low Label</Label>
                        <input type="text" value={q.ratingLabels?.low || ''} 
                          onChange={e => updateQuestion(idx, { ratingLabels: { ...q.ratingLabels, low: e.target.value, high: q.ratingLabels?.high || '' } })}
                          placeholder="Poor" className="input-sm text-xs" />
                      </div>
                      <div className="col-span-4">
                        <Label>High Label</Label>
                        <input type="text" value={q.ratingLabels?.high || ''} 
                          onChange={e => updateQuestion(idx, { ratingLabels: { ...q.ratingLabels, high: e.target.value, low: q.ratingLabels?.low || '' } })}
                          placeholder="Excellent" className="input-sm text-xs" />
                      </div>
                    </div>
                  )}

                  {/* Number Options */}
                  {q.type === 'number' && (
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-4">
                        <Label>Min Value</Label>
                        <input type="number" value={q.min ?? ''} onChange={e => updateQuestion(idx, { min: e.target.value ? parseInt(e.target.value) : undefined })} 
                          placeholder="0" className="input-sm text-xs" />
                      </div>
                      <div className="col-span-4">
                        <Label>Max Value</Label>
                        <input type="number" value={q.max ?? ''} onChange={e => updateQuestion(idx, { max: e.target.value ? parseInt(e.target.value) : undefined })} 
                          placeholder="100" className="input-sm text-xs" />
                      </div>
                      <div className="col-span-4">
                        <Label>Placeholder</Label>
                        <input type="text" value={q.placeholder || ''} onChange={e => updateQuestion(idx, { placeholder: e.target.value })}
                          placeholder="Enter a number..." className="input-sm text-xs" />
                      </div>
                    </div>
                  )}

                  {/* Text Options */}
                  {q.type === 'text' && (
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-3">
                        <Label>Input Type</Label>
                        <select value={q.multiline ? 'multiline' : 'single'} 
                          onChange={e => updateQuestion(idx, { multiline: e.target.value === 'multiline' })} className="input-sm text-xs">
                          <option value="single">Single Line</option>
                          <option value="multiline">Multi-line</option>
                        </select>
                      </div>
                      <div className="col-span-3">
                        <Label>Max Length</Label>
                        <input type="number" value={q.maxLength || ''} onChange={e => updateQuestion(idx, { maxLength: parseInt(e.target.value) || undefined })}
                          placeholder="500" className="input-sm text-xs" />
                      </div>
                      <div className="col-span-6">
                        <Label>Placeholder</Label>
                        <input type="text" value={q.placeholder || ''} onChange={e => updateQuestion(idx, { placeholder: e.target.value })}
                          placeholder="Enter your answer..." className="input-sm text-xs" />
                      </div>
                    </div>
                  )}

                  {/* Email Options */}
                  {q.type === 'email' && (
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-6">
                        <Label>Placeholder</Label>
                        <input type="text" value={q.placeholder || ''} onChange={e => updateQuestion(idx, { placeholder: e.target.value })}
                          placeholder="your@email.com" className="input-sm text-xs" />
                      </div>
                      <div className="col-span-6 flex items-end pb-1">
                        <span className="text-xs text-slate-500">📧 Email format will be validated</span>
                      </div>
                    </div>
                  )}

                  {/* Date Options */}
                  {q.type === 'date' && (
                    <div className="grid grid-cols-12 gap-2">
                      <div className="col-span-6">
                        <Label>Placeholder</Label>
                        <input type="text" value={q.placeholder || ''} onChange={e => updateQuestion(idx, { placeholder: e.target.value })}
                          placeholder="Select a date..." className="input-sm text-xs" />
                      </div>
                      <div className="col-span-6 flex items-end pb-1">
                        <span className="text-xs text-slate-500">📅 Date picker will be shown</span>
                      </div>
                    </div>
                  )}

                  {/* Yes/No has no extra options */}
                  {q.type === 'yes_no' && (
                    <div className="text-xs text-slate-500 py-2">
                      ✅ User will see Yes/No buttons
                    </div>
                  )}

                  {/* User Insights - Link to User Profile (only for user_insights category) */}
                  {form.survey_category === 'user_insights' && (
                    <div className="border-t border-white/5 pt-3 mt-3">
                      <div className="grid grid-cols-12 gap-2">
                        <div className="col-span-6">
                          <Label>👤 Link to User Profile</Label>
                          <select value={q.linkToUserProfile || ''} onChange={e => updateQuestion(idx, { linkToUserProfile: e.target.value || undefined })} className="input-sm text-xs">
                            {USER_PROFILE_FIELDS.map(f => (
                              <option key={f.value} value={f.value}>{f.label}</option>
                            ))}
                          </select>
                        </div>
                        <div className="col-span-6 flex items-end pb-1">
                          {q.linkToUserProfile && (
                            <span className="text-xs text-emerald-400">✓ Answer will update user&apos;s {q.linkToUserProfile}</span>
                          )}
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Response Actions - for choice-based questions */}
                  {(q.type === 'single_choice' || q.type === 'yes_no' || q.type === 'dropdown') && (q.options?.length || q.type === 'yes_no') && (
                    <div className="border-t border-white/5 pt-3 mt-3">
                      <Label>⚡ Response Actions (optional)</Label>
                      <div className="text-xs text-slate-500 mb-2">Trigger actions based on specific answers</div>
                      <div className="space-y-2">
                        {(q.type === 'yes_no' ? ['Yes', 'No'] : q.options || []).map((option, optIdx) => {
                          const existingAction = q.responseActions?.find(a => a.triggerValue === option);
                          return (
                            <div key={optIdx} className="flex items-center gap-2 bg-slate-900/50 rounded p-2">
                              <span className="text-xs text-slate-400 w-24 truncate" title={option}>{option}</span>
                              <select 
                                value={existingAction?.actionType || 'none'} 
                                onChange={e => {
                                  const newActions = [...(q.responseActions || [])].filter(a => a.triggerValue !== option);
                                  if (e.target.value !== 'none') {
                                    newActions.push({ triggerValue: option, actionType: e.target.value as ResponseAction['actionType'], actionValue: '', actionTitle: '' });
                                  }
                                  updateQuestion(idx, { responseActions: newActions });
                                }}
                                className="input-sm text-xs flex-1"
                              >
                                <option value="none">No action</option>
                                <option value="show_modal">Show Modal</option>
                                <option value="open_link">Open Link</option>
                                <option value="open_screen">Open Screen</option>
                              </select>
                              {existingAction && existingAction.actionType !== 'none' && (
                                <>
                                  {existingAction.actionType === 'show_modal' && (
                                    <input type="text" value={existingAction.actionValue || ''} 
                                      onChange={e => {
                                        const newActions = [...(q.responseActions || [])];
                                        const actionIdx = newActions.findIndex(a => a.triggerValue === option);
                                        if (actionIdx >= 0) newActions[actionIdx] = { ...newActions[actionIdx], actionValue: e.target.value };
                                        updateQuestion(idx, { responseActions: newActions });
                                      }}
                                      placeholder="Modal message..." className="input-sm text-xs flex-1" />
                                  )}
                                  {existingAction.actionType === 'open_link' && (
                                    <input type="url" value={existingAction.actionValue || ''} 
                                      onChange={e => {
                                        const newActions = [...(q.responseActions || [])];
                                        const actionIdx = newActions.findIndex(a => a.triggerValue === option);
                                        if (actionIdx >= 0) newActions[actionIdx] = { ...newActions[actionIdx], actionValue: e.target.value };
                                        updateQuestion(idx, { responseActions: newActions });
                                      }}
                                      placeholder="https://..." className="input-sm text-xs flex-1" />
                                  )}
                                </>
                              )}
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  )}

                  {/* Question Images (optional) - for quizzes */}
                  <div className="border-t border-white/5 pt-3 mt-3">
                    <Label>🖼️ Question Images (optional)</Label>
                    <div className="text-xs text-slate-500 mb-2">Add image URLs (one per line). Multiple images will show as a carousel.</div>
                    <textarea 
                      value={(q.images || []).join('\n')} 
                      onChange={e => updateQuestion(idx, { images: e.target.value.split('\n') })}
                      onBlur={e => updateQuestion(idx, { images: e.target.value.split('\n').filter(url => url.trim()) })}
                      onKeyDown={e => {
                        // Allow Enter key to create new lines
                        if (e.key === 'Enter') {
                          e.stopPropagation();
                        }
                      }}
                      placeholder="https://example.com/image1.jpg&#10;https://example.com/image2.jpg"
                      className="input-sm text-xs min-h-[60px] font-mono"
                      rows={3}
                    />
                    {(q.images?.length || 0) > 0 && (
                      <div className="flex gap-2 mt-2 flex-wrap">
                        {q.images?.map((url, imgIdx) => (
                          <div key={imgIdx} className="relative group">
                            <img src={url} alt={`Preview ${imgIdx + 1}`} className="w-16 h-16 object-cover rounded border border-white/10" 
                              onError={(e) => { (e.target as HTMLImageElement).src = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect fill="%23374151" width="64" height="64"/><text x="50%" y="50%" fill="%239CA3AF" font-size="10" text-anchor="middle" dy=".3em">Error</text></svg>'; }} />
                            <button 
                              type="button"
                              onClick={() => updateQuestion(idx, { images: q.images?.filter((_, i) => i !== imgIdx) })}
                              className="absolute -top-1 -right-1 w-4 h-4 bg-rose-500 rounded-full text-white text-xs opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center"
                            >×</button>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}

            {/* Quick Add Buttons */}
            {form.questions.length > 0 && (
              <div className="flex flex-wrap gap-2 pt-2 border-t border-white/5">
                <span className="text-xs text-slate-500 py-1">Quick add:</span>
                {(['single_choice', 'text', 'rating', 'yes_no'] as const).map(type => (
                  <button key={type} onClick={() => addQuestion(type)}
                    className="px-2 py-1 text-xs bg-slate-700 hover:bg-slate-600 text-slate-300 rounded flex items-center gap-1">
                    {getQuestionTypeIcon(type)} {getQuestionTypeLabel(type)}
                  </button>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

        {/* Footer */}
        <div className="border-t border-white/10 px-4 py-3 flex items-center justify-between bg-slate-800/50">
          <button onClick={onCancel} className="px-3 py-1.5 text-slate-400 hover:text-white text-sm">Cancel</button>
          <button onClick={handleSubmit} disabled={saving} className="px-4 py-1.5 bg-indigo-500 hover:bg-indigo-600 disabled:opacity-50 text-white rounded text-sm font-medium">
            {saving ? 'Saving...' : isEditing ? 'Update' : 'Publish'}
          </button>
        </div>
      </div>

      {/* Preview Panel - Right Side */}
      <div className="col-span-4">
        <div className="bg-slate-900 rounded-2xl border border-white/10 overflow-hidden sticky top-4">
          <div className="px-4 py-3 border-b border-white/10 bg-slate-800/50">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-medium text-slate-300">📱 Preview</h3>
                <p className="text-xs text-slate-500 mt-1">How it appears in the app</p>
              </div>
              <div className="text-xs">
                <select 
                  value={form.surface} 
                  onChange={e => updateField('surface', e.target.value as AnnouncementSurface)}
                  className="bg-slate-700 border border-slate-600 rounded px-2 py-1 text-slate-300 text-xs"
                >
                  <option value="home_banner">🏠 Banner</option>
                  <option value="modal">📱 Modal</option>
                  <option value="inbox">📬 Inbox</option>
                </select>
              </div>
            </div>
          </div>
          
          <div className="p-4 space-y-4">
            {form.surface === 'home_banner' && <BannerPreview form={form} />}
            {form.surface === 'modal' && <ModalPreview form={form} />}
            {form.surface === 'inbox' && <InboxPreview form={form} />}
            
            {/* Preview Info */}
            <div className="bg-slate-800/50 rounded-lg p-3 text-xs text-slate-400">
              <div className="font-medium mb-2">ℹ️ Preview Info</div>
              <div className="space-y-1">
                <div>Surface: <span className="text-slate-300">{form.surface.replace('_', ' ')}</span></div>
                <div>Type: <span className="text-slate-300">{form.kind}</span></div>
                <div>Importance: <span className="text-slate-300">{form.importance}</span></div>
                {form.dismissible_mode && (
                  <div>Dismissible: <span className="text-slate-300">{form.dismissible_mode}</span></div>
                )}
                {form.action_type !== 'none' && (
                  <div>Action: <span className="text-slate-300">{form.action_type}</span></div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        .input-sm {
          width: 100%;
          background: rgb(30 41 59);
          border: 1px solid rgba(255,255,255,0.1);
          border-radius: 0.375rem;
          padding: 0.375rem 0.5rem;
          color: white;
          font-size: 0.75rem;
        }
        .input-sm:focus {
          outline: none;
          border-color: rgb(99 102 241);
        }
        .input-sm::placeholder {
          color: rgb(100 116 139);
        }
      `}</style>
    </div>
  );
}

function Label({ children }: { children: React.ReactNode }) {
  return <label className="block text-xs text-slate-400 mb-1">{children}</label>;
}
