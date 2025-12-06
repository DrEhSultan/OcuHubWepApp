module.exports = [
"[externals]/jsonwebtoken [external] (jsonwebtoken, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("jsonwebtoken", () => require("jsonwebtoken"));

module.exports = mod;
}),
"[externals]/cookie [external] (cookie, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("cookie", () => require("cookie"));

module.exports = mod;
}),
"[project]/lib/adminAuth.ts [ssr] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "clearAdminCookie",
    ()=>clearAdminCookie,
    "getAdminSessionFromRequest",
    ()=>getAdminSessionFromRequest,
    "getTokenFromRequest",
    ()=>getTokenFromRequest,
    "requireAdminApi",
    ()=>requireAdminApi,
    "setAdminCookie",
    ()=>setAdminCookie,
    "signAdminToken",
    ()=>signAdminToken,
    "verifyAdminToken",
    ()=>verifyAdminToken
]);
var __TURBOPACK__imported__module__$5b$externals$5d2f$jsonwebtoken__$5b$external$5d$__$28$jsonwebtoken$2c$__cjs$29$__ = __turbopack_context__.i("[externals]/jsonwebtoken [external] (jsonwebtoken, cjs)");
var __TURBOPACK__imported__module__$5b$externals$5d2f$cookie__$5b$external$5d$__$28$cookie$2c$__cjs$29$__ = __turbopack_context__.i("[externals]/cookie [external] (cookie, cjs)");
;
;
const ADMIN_COOKIE_NAME = 'ocuhub_admin_token';
const getSecret = ()=>{
    const secret = process.env.ADMIN_JWT_SECRET;
    if (!secret) {
        throw new Error('ADMIN_JWT_SECRET is not defined');
    }
    return secret;
};
const signAdminToken = (payload)=>{
    return __TURBOPACK__imported__module__$5b$externals$5d2f$jsonwebtoken__$5b$external$5d$__$28$jsonwebtoken$2c$__cjs$29$__["default"].sign(payload, getSecret(), {
        expiresIn: '12h'
    });
};
const verifyAdminToken = (token)=>{
    if (!token) return null;
    try {
        return __TURBOPACK__imported__module__$5b$externals$5d2f$jsonwebtoken__$5b$external$5d$__$28$jsonwebtoken$2c$__cjs$29$__["default"].verify(token, getSecret());
    } catch  {
        return null;
    }
};
const setAdminCookie = (res, token)=>{
    res.setHeader('Set-Cookie', (0, __TURBOPACK__imported__module__$5b$externals$5d2f$cookie__$5b$external$5d$__$28$cookie$2c$__cjs$29$__["serialize"])(ADMIN_COOKIE_NAME, token, {
        httpOnly: true,
        secure: ("TURBOPACK compile-time value", "development") === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 12
    }));
};
const clearAdminCookie = (res)=>{
    res.setHeader('Set-Cookie', (0, __TURBOPACK__imported__module__$5b$externals$5d2f$cookie__$5b$external$5d$__$28$cookie$2c$__cjs$29$__["serialize"])(ADMIN_COOKIE_NAME, '', {
        httpOnly: true,
        secure: ("TURBOPACK compile-time value", "development") === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 0
    }));
};
const getTokenFromRequest = (req)=>{
    if (!req?.headers?.cookie) {
        return undefined;
    }
    const cookies = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$cookie__$5b$external$5d$__$28$cookie$2c$__cjs$29$__["parse"])(req.headers.cookie);
    return cookies[ADMIN_COOKIE_NAME];
};
const getAdminSessionFromRequest = (req)=>{
    const token = getTokenFromRequest(req);
    return verifyAdminToken(token);
};
const requireAdminApi = (req, res)=>{
    const session = getAdminSessionFromRequest(req);
    if (!session) {
        res.status(401).json({
            error: 'Unauthorized'
        });
        return null;
    }
    return session;
};
}),
"[project]/pages/admin/index.tsx [ssr] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "default",
    ()=>__TURBOPACK__default__export__,
    "getServerSideProps",
    ()=>getServerSideProps
]);
var __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__ = __turbopack_context__.i("[externals]/react/jsx-dev-runtime [external] (react/jsx-dev-runtime, cjs)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$head$2e$js__$5b$ssr$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/head.js [ssr] (ecmascript)");
var __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__ = __turbopack_context__.i("[externals]/react [external] (react, cjs)");
var __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$adminAuth$2e$ts__$5b$ssr$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/lib/adminAuth.ts [ssr] (ecmascript)");
;
;
;
;
const RANGE_OPTIONS = [
    7,
    30,
    90
];
const AdminDashboardPage = ({ admin })=>{
    const [activeTab, setActiveTab] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])('home');
    const [days, setDays] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(30);
    const [data, setData] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [loading, setLoading] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(true);
    const [error, setError] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [toolLeaderboard, setToolLeaderboard] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])([]);
    const [toolLoading, setToolLoading] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const [toolError, setToolError] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [selectedToolId, setSelectedToolId] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [toolDrilldown, setToolDrilldown] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [toolDetailsOpen, setToolDetailsOpen] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const selectedToolRow = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useMemo"])(()=>toolLeaderboard.find((t)=>t.toolId === selectedToolId) ?? null, [
        selectedToolId,
        toolLeaderboard
    ]);
    const [feedbackTypeFilter, setFeedbackTypeFilter] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [allFeedbacks, setAllFeedbacks] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])([]);
    const [feedbacksLoading, setFeedbacksLoading] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const [announcements, setAnnouncements] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])([]);
    const [announcementsLoading, setAnnouncementsLoading] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const [announcementsError, setAnnouncementsError] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [announcementToCreate, setAnnouncementToCreate] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const [newAnnouncementForm, setNewAnnouncementForm] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])({
        title: '',
        content: '',
        severity: 'info',
        expiresAt: ''
    });
    const [usersLoading, setUsersLoading] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(false);
    const [usersError, setUsersError] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])(null);
    const [users, setUsers] = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useState"])([]);
    // Load main analytics
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        let cancelled = false;
        const load = async ()=>{
            setLoading(true);
            setError(null);
            try {
                const response = await fetch(`/api/admin/analytics?days=${days}`);
                if (response.status === 401) {
                    window.location.href = '/admin/login';
                    return;
                }
                if (!response.ok) {
                    const payload = await response.json();
                    if (!cancelled) {
                        setError(payload.error ?? 'Failed to load analytics.');
                    }
                    return;
                }
                const payload = await response.json();
                if (!cancelled) {
                    setData(payload);
                    setAnnouncements(payload.announcements);
                }
            } catch (err) {
                if (!cancelled) {
                    setError('Network error while loading analytics.');
                }
            } finally{
                if (!cancelled) {
                    setLoading(false);
                }
            }
        };
        load();
        return ()=>{
            cancelled = true;
        };
    }, [
        days
    ]);
    // Load tool leaderboard
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        let cancelled = false;
        const loadTools = async ()=>{
            setToolLoading(true);
            setToolError(null);
            try {
                const response = await fetch(`/api/admin/tool-usage?days=${days}`);
                if (response.status === 401) {
                    window.location.href = '/admin/login';
                    return;
                }
                if (!response.ok) {
                    const payload = await response.json();
                    if (!cancelled) {
                        setToolError(payload.error ?? 'Failed to load tool usage.');
                    }
                    return;
                }
                const payload = await response.json();
                const tools = payload.tools ?? [];
                if (!cancelled) {
                    setToolLeaderboard(tools);
                    if (!selectedToolId && tools.length > 0) {
                        setSelectedToolId(tools[0].toolId);
                    }
                }
            } catch (err) {
                if (!cancelled) {
                    setToolError('Network error while loading tool usage.');
                }
            } finally{
                if (!cancelled) {
                    setToolLoading(false);
                }
            }
        };
        loadTools();
        return ()=>{
            cancelled = true;
        };
    }, [
        days
    ]);
    // Load tool drilldown
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        let cancelled = false;
        const loadDrilldown = async ()=>{
            if (!selectedToolId) return;
            console.log('🔍 Loading drilldown for tool:', selectedToolId);
            setToolLoading(true);
            setToolError(null);
            try {
                const url = `/api/admin/tool-usage?toolId=${encodeURIComponent(selectedToolId)}&days=${days}`;
                console.log('📡 Fetching:', url);
                const response = await fetch(url);
                console.log('✅ Response status:', response.status);
                if (response.status === 401) {
                    window.location.href = '/admin/login';
                    return;
                }
                if (!response.ok) {
                    const payload = await response.json();
                    console.error('❌ API error:', payload);
                    if (!cancelled) {
                        setToolError(payload.error ?? 'Failed to load tool drilldown.');
                    }
                    return;
                }
                const payload = await response.json();
                console.log('📊 Drilldown data:', payload);
                if (!cancelled) {
                    setToolDrilldown(payload);
                }
            } catch (err) {
                console.error('💥 Drilldown error:', err);
                if (!cancelled) {
                    setToolError('Network error while loading tool drilldown.');
                }
            } finally{
                if (!cancelled) {
                    setToolLoading(false);
                }
            }
        };
        loadDrilldown();
        return ()=>{
            cancelled = true;
        };
    }, [
        selectedToolId,
        days
    ]);
    // Load users list
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        if (activeTab !== 'users') return;
        let cancelled = false;
        const loadUsers = async ()=>{
            setUsersLoading(true);
            setUsersError(null);
            try {
                const response = await fetch('/api/admin/users?limit=200');
                if (response.status === 401) {
                    window.location.href = '/admin/login';
                    return;
                }
                if (!response.ok) {
                    const payload = await response.json();
                    if (!cancelled) {
                        setUsersError(payload.error ?? 'Failed to load users');
                    }
                    return;
                }
                const payload = await response.json();
                if (!cancelled) {
                    setUsers(payload.users ?? []);
                }
            } catch (err) {
                if (!cancelled) {
                    setUsersError('Network error while loading users.');
                }
            } finally{
                if (!cancelled) {
                    setUsersLoading(false);
                }
            }
        };
        loadUsers();
        return ()=>{
            cancelled = true;
        };
    }, [
        activeTab
    ]);
    // Load all feedbacks
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        if (activeTab !== 'feedbacks') return;
        let cancelled = false;
        const loadFeedbacks = async ()=>{
            setFeedbacksLoading(true);
            try {
                const response = await fetch(`/api/admin/feedbacks?days=${days}`);
                if (response.ok) {
                    const payload = await response.json();
                    if (!cancelled) {
                        setAllFeedbacks(payload.feedbacks || []);
                    }
                }
            } catch (err) {
                console.error('Error loading feedbacks:', err);
            } finally{
                if (!cancelled) {
                    setFeedbacksLoading(false);
                }
            }
        };
        loadFeedbacks();
        return ()=>{
            cancelled = true;
        };
    }, [
        activeTab,
        days
    ]);
    // Load announcements
    (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useEffect"])(()=>{
        if (activeTab !== 'announcements') return;
        let cancelled = false;
        const loadAnnouncements = async ()=>{
            setAnnouncementsLoading(true);
            setAnnouncementsError(null);
            try {
                const response = await fetch('/api/admin/announcements');
                if (response.ok) {
                    const payload = await response.json();
                    if (!cancelled) {
                        setAnnouncements(payload.announcements.map((item)=>({
                                id: item.id,
                                title: item.title,
                                severity: item.severity,
                                status: item.status,
                                publishedAt: item.createdAt,
                                expiresAt: item.expiresAt
                            })));
                    }
                } else {
                    setAnnouncementsError('Failed to load announcements');
                }
            } catch (err) {
                console.error('Error loading announcements:', err);
                if (!cancelled) {
                    setAnnouncementsError('Error loading announcements');
                }
            } finally{
                if (!cancelled) {
                    setAnnouncementsLoading(false);
                }
            }
        };
        loadAnnouncements();
        return ()=>{
            cancelled = true;
        };
    }, [
        activeTab
    ]);
    const handleLogout = async ()=>{
        await fetch('/api/admin/logout', {
            method: 'POST'
        });
        window.location.href = '/admin/login';
    };
    const handleCreateAnnouncement = async ()=>{
        if (!newAnnouncementForm.title.trim()) {
            alert('Title is required');
            return;
        }
        try {
            const response = await fetch('/api/admin/announcements', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    title: newAnnouncementForm.title,
                    content: newAnnouncementForm.content,
                    severity: newAnnouncementForm.severity,
                    status: 'published',
                    expiresAt: newAnnouncementForm.expiresAt || null
                })
            });
            if (response.ok) {
                setAnnouncements([]);
                setAnnouncementToCreate(false);
                setNewAnnouncementForm({
                    title: '',
                    content: '',
                    severity: 'info',
                    expiresAt: ''
                });
                // Reload announcements
                const listResponse = await fetch('/api/admin/announcements');
                const payload = await listResponse.json();
                setAnnouncements(payload.announcements.map((item)=>({
                        id: item.id,
                        title: item.title,
                        severity: item.severity,
                        status: item.status,
                        publishedAt: item.createdAt,
                        expiresAt: item.expiresAt
                    })));
                alert('Announcement created successfully');
            } else {
                const payload = await response.json().catch(()=>({}));
                alert(payload?.error ? `Failed to create announcement: ${payload.error}` : 'Failed to create announcement');
            }
        } catch (err) {
            console.error('Error creating announcement:', err);
            alert('Error creating announcement');
        }
    };
    const handleDeleteAnnouncement = async (id)=>{
        if (!confirm('Are you sure you want to delete this announcement?')) {
            return;
        }
        try {
            const response = await fetch(`/api/admin/announcements?id=${id}`, {
                method: 'DELETE'
            });
            if (response.ok) {
                setAnnouncements(announcements.filter((a)=>a.id !== id));
                alert('Announcement deleted successfully');
            } else {
                alert('Failed to delete announcement');
            }
        } catch (err) {
            console.error('Error deleting announcement:', err);
            alert('Error deleting announcement');
        }
    };
    const formatNumber = (value)=>new Intl.NumberFormat('en-US', {
            maximumFractionDigits: 0
        }).format(value ?? 0);
    const formatDateTime = (value)=>value ? new Intl.DateTimeFormat('en-US', {
            dateStyle: 'medium',
            timeStyle: 'short'
        }).format(new Date(value)) : '—';
    const avgSessionMinutes = data?.overview ? (data.overview.avgSessionDurationSeconds / 60).toFixed(1) : '0.0';
    const filteredFeedbacks = feedbackTypeFilter ? allFeedbacks.filter((f)=>f.type === feedbackTypeFilter) : allFeedbacks;
    const feedbacksByTool = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react__$5b$external$5d$__$28$react$2c$__cjs$29$__["useMemo"])(()=>{
        const groups = new Map();
        filteredFeedbacks.forEach((f)=>{
            const toolId = f.toolId ?? 'unknown';
            const toolName = f.toolName ?? 'Unknown Tool';
            if (!groups.has(toolId)) {
                groups.set(toolId, {
                    toolId,
                    toolName,
                    feedbacks: []
                });
            }
            groups.get(toolId)?.feedbacks.push(f);
        });
        // sort groups by number of feedbacks desc
        return Array.from(groups.values()).sort((a, b)=>b.feedbacks.length - a.feedbacks.length);
    }, [
        filteredFeedbacks
    ]);
    const feedbackTypes = [
        'bug',
        'feature',
        'general'
    ];
    return /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(__TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["Fragment"], {
        children: [
            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(__TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$head$2e$js__$5b$ssr$5d$__$28$ecmascript$29$__["default"], {
                children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("title", {
                    children: "OcuHub Admin Console"
                }, void 0, false, {
                    fileName: "[project]/pages/admin/index.tsx",
                    lineNumber: 406,
                    columnNumber: 9
                }, ("TURBOPACK compile-time value", void 0))
            }, void 0, false, {
                fileName: "[project]/pages/admin/index.tsx",
                lineNumber: 405,
                columnNumber: 7
            }, ("TURBOPACK compile-time value", void 0)),
            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                className: "min-h-screen bg-slate-950 text-white",
                children: [
                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("header", {
                        className: "border-b border-white/5 bg-slate-900/60 backdrop-blur sticky top-0 z-50",
                        children: [
                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "max-w-7xl mx-auto flex flex-col gap-4 px-6 py-6 sm:flex-row sm:items-center sm:justify-between",
                                children: [
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-xs uppercase tracking-[0.5em] text-indigo-300",
                                                children: "Admin Console"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 412,
                                                columnNumber: 15
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h1", {
                                                className: "text-3xl font-semibold",
                                                children: "OcuHub Intelligence Dashboard"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 413,
                                                columnNumber: 15
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-sm text-slate-400",
                                                children: [
                                                    "Signed in as ",
                                                    admin.displayName ?? admin.email
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 414,
                                                columnNumber: 15
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 411,
                                        columnNumber: 13
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                        className: "flex items-center gap-3",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "rounded-full bg-emerald-500/20 px-4 py-2 text-sm text-emerald-200",
                                                children: [
                                                    "Role: ",
                                                    admin.role
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 417,
                                                columnNumber: 15
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                onClick: handleLogout,
                                                className: "rounded-xl bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700 border border-white/10",
                                                children: "Sign out"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 418,
                                                columnNumber: 15
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 416,
                                        columnNumber: 13
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 410,
                                columnNumber: 11
                            }, ("TURBOPACK compile-time value", void 0)),
                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "border-t border-white/5 flex gap-2 px-6 overflow-x-auto bg-slate-900/40",
                                children: [
                                    'home',
                                    'tools',
                                    'feedbacks',
                                    'announcements',
                                    'users',
                                    'sessions'
                                ].map((tab)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                        onClick: ()=>setActiveTab(tab),
                                        className: `px-4 py-3 text-sm font-medium border-b-2 whitespace-nowrap transition-colors ${activeTab === tab ? 'border-indigo-500 text-indigo-300' : 'border-transparent text-slate-400 hover:text-slate-300'}`,
                                        children: tab.charAt(0).toUpperCase() + tab.slice(1)
                                    }, tab, false, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 430,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)))
                            }, void 0, false, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 428,
                                columnNumber: 11
                            }, ("TURBOPACK compile-time value", void 0)),
                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "border-t border-white/5 px-6 py-3 flex gap-2",
                                children: RANGE_OPTIONS.map((option)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                        onClick: ()=>setDays(option),
                                        className: `rounded-full px-4 py-2 text-sm font-medium border ${days === option ? 'bg-indigo-500 text-white border-indigo-400' : 'bg-slate-800/60 text-slate-200 border-white/10 hover:border-indigo-500/40'}`,
                                        children: [
                                            "Last ",
                                            option,
                                            "d"
                                        ]
                                    }, option, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 447,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)))
                            }, void 0, false, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 445,
                                columnNumber: 11
                            }, ("TURBOPACK compile-time value", void 0))
                        ]
                    }, void 0, true, {
                        fileName: "[project]/pages/admin/index.tsx",
                        lineNumber: 409,
                        columnNumber: 9
                    }, ("TURBOPACK compile-time value", void 0)),
                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("main", {
                        className: "max-w-7xl mx-auto px-4 py-10",
                        children: [
                            activeTab === 'home' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "space-y-8",
                                children: [
                                    error && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                        className: "rounded-xl border border-rose-400/30 bg-rose-950/40 px-4 py-3 text-sm text-rose-200",
                                        children: error
                                    }, void 0, false, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 466,
                                        columnNumber: 25
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                                className: "text-xl font-semibold mb-6",
                                                children: "Usage Overview"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 470,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "grid gap-4 md:grid-cols-2 lg:grid-cols-4",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Total Users",
                                                        value: formatNumber(data?.overview?.totalUsers)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 472,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Active Users",
                                                        value: `${formatNumber(data?.overview?.activeUsers)} / ${days}d`
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 473,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Sessions",
                                                        value: formatNumber(data?.overview?.sessionCount)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 474,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Avg Session (min)",
                                                        value: avgSessionMinutes
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 475,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Tool Events",
                                                        value: formatNumber(data?.overview?.toolEventCount)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 476,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Feedback",
                                                        value: formatNumber(data?.overview?.feedbackCount)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 477,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Countries",
                                                        value: formatNumber(data?.overview?.countryCount)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 478,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Last Activity",
                                                        value: formatDateTime(data?.overview?.lastActivity),
                                                        isMono: true
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 479,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 471,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 469,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                        className: "grid gap-6 lg:grid-cols-2",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                                className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h3", {
                                                        className: "text-lg font-semibold mb-4",
                                                        children: "Top Tools"
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 486,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "space-y-3",
                                                        children: (data?.topTools ?? []).slice(0, 5).map((tool)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                className: "flex items-center justify-between rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3",
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                        children: [
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                className: "font-medium",
                                                                                children: tool.toolName
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 491,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                className: "text-xs text-slate-400",
                                                                                children: [
                                                                                    formatNumber(tool.uniqueUsers),
                                                                                    " users"
                                                                                ]
                                                                            }, void 0, true, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 492,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0))
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 490,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                        className: "text-right",
                                                                        children: [
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                className: "text-sm font-semibold",
                                                                                children: [
                                                                                    formatNumber(tool.totalEvents),
                                                                                    " events"
                                                                                ]
                                                                            }, void 0, true, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 495,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                className: "text-xs text-slate-500",
                                                                                children: [
                                                                                    formatNumber(tool.totalSessions),
                                                                                    " sessions"
                                                                                ]
                                                                            }, void 0, true, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 496,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0))
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 494,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, tool.toolId, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 489,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)))
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 487,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 485,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                                className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h3", {
                                                        className: "text-lg font-semibold mb-4",
                                                        children: "Latest Announcements"
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 505,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "space-y-3",
                                                        children: announcements.slice(0, 5).map((item)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                className: "rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3",
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                        className: "flex items-center justify-between",
                                                                        children: [
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                className: "font-medium text-sm",
                                                                                children: item.title
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 510,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                                className: `text-xs px-2 py-1 rounded-full uppercase tracking-wide ${item.severity === 'critical' ? 'bg-rose-500/20 text-rose-200' : item.severity === 'warning' ? 'bg-amber-500/20 text-amber-100' : 'bg-emerald-500/20 text-emerald-100'}`,
                                                                                children: item.status
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 511,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0))
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 509,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                        className: "text-xs text-slate-400 mt-1",
                                                                        children: formatDateTime(item.publishedAt)
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 521,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, item.id, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 508,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)))
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 506,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 504,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 483,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h3", {
                                                className: "text-lg font-semibold mb-4",
                                                children: "Latest Feedbacks"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 530,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "space-y-3",
                                                children: (data?.feedbackSummary ?? []).map((item)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "flex items-center justify-between rounded-lg border border-white/5 bg-slate-800/50 px-4 py-3",
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                        className: "font-medium capitalize",
                                                                        children: item.feedbackType
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 535,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                        className: "text-xs text-slate-400",
                                                                        children: [
                                                                            formatNumber(item.feedbackCount),
                                                                            " feedbacks"
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 536,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 534,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                className: "text-right",
                                                                children: [
                                                                    item.avgRating && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                        className: "text-sm text-amber-300",
                                                                        children: [
                                                                            "⭐ ",
                                                                            item.avgRating.toFixed(1)
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 539,
                                                                        columnNumber: 44
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                        className: "text-xs text-slate-500",
                                                                        children: formatDateTime(item.lastFeedbackAt)
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 540,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 538,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, item.feedbackType, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 533,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0)))
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 531,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 529,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 465,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0)),
                            activeTab === 'tools' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "space-y-6",
                                children: [
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                                className: "text-xl font-semibold mb-4",
                                                children: "Tool Leaderboard"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 553,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            toolError && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-rose-300 text-sm mb-3",
                                                children: toolError
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 554,
                                                columnNumber: 31
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "overflow-x-auto",
                                                children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("table", {
                                                    className: "w-full text-sm",
                                                    children: [
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("thead", {
                                                            children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                                className: "text-left text-slate-400 border-b border-white/5",
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Tool"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 559,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Events"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 560,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Users"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 561,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Sessions"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 562,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Countries"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 563,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Last Used"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 564,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 558,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 557,
                                                            columnNumber: 21
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tbody", {
                                                            children: toolLeaderboard.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                                children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    colSpan: 6,
                                                                    className: "py-4 text-center text-slate-500",
                                                                    children: "No usage yet."
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 570,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 569,
                                                                columnNumber: 25
                                                            }, ("TURBOPACK compile-time value", void 0)) : toolLeaderboard.map((row)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                                    className: `border-t border-white/5 cursor-pointer hover:bg-slate-800/50 ${selectedToolId === row.toolId && toolDetailsOpen ? 'bg-indigo-500/10' : ''}`,
                                                                    onClick: ()=>{
                                                                        setSelectedToolId(row.toolId);
                                                                        setToolDetailsOpen(true);
                                                                    },
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-indigo-100",
                                                                            children: row.toolName
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 584,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2",
                                                                            children: formatNumber(row.events)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 585,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2",
                                                                            children: formatNumber(row.uniqueUsers)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 586,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2",
                                                                            children: formatNumber(row.uniqueSessions)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 587,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2",
                                                                            children: formatNumber(row.countries)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 588,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-xs text-slate-400",
                                                                            children: formatDateTime(row.lastEventAt)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 589,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, row.toolId, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 574,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)))
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 567,
                                                            columnNumber: 21
                                                        }, ("TURBOPACK compile-time value", void 0))
                                                    ]
                                                }, void 0, true, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 556,
                                                    columnNumber: 19
                                                }, ("TURBOPACK compile-time value", void 0))
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 555,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 552,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    toolDetailsOpen && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                        className: "fixed inset-0 z-50 flex items-start justify-center bg-black/50 backdrop-blur-sm px-4 py-10",
                                        children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                            className: "w-full max-w-6xl rounded-2xl bg-slate-950 border border-white/10 shadow-2xl overflow-hidden",
                                            children: [
                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                    className: "flex flex-col gap-3 border-b border-white/5 px-6 py-4 md:flex-row md:items-center md:justify-between",
                                                    children: [
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                            children: [
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                    className: "text-xs uppercase tracking-[0.3em] text-indigo-300",
                                                                    children: "Tool details"
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 604,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h3", {
                                                                    className: "text-lg font-semibold text-white",
                                                                    children: toolDrilldown?.summary.toolName ?? selectedToolRow?.toolName ?? 'Loading...'
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 605,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                    className: "text-sm text-slate-400",
                                                                    children: toolDrilldown ? 'Detailed usage for the selected tool' : 'Loading usage data...'
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 608,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, void 0, true, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 603,
                                                            columnNumber: 23
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                            className: "flex flex-wrap items-center gap-2",
                                                            children: [
                                                                selectedToolRow && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(__TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["Fragment"], {
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                            className: "px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200",
                                                                            children: [
                                                                                "Events: ",
                                                                                formatNumber(selectedToolRow.events)
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 615,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                            className: "px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200",
                                                                            children: [
                                                                                "Users: ",
                                                                                formatNumber(selectedToolRow.uniqueUsers)
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 618,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                            className: "px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200",
                                                                            children: [
                                                                                "Sessions: ",
                                                                                formatNumber(selectedToolRow.uniqueSessions)
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 621,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                            className: "px-3 py-2 rounded-lg bg-slate-800/70 border border-white/5 text-xs text-slate-200",
                                                                            children: [
                                                                                "Countries: ",
                                                                                formatNumber(selectedToolRow.countries)
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 624,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                                    onClick: ()=>setToolDetailsOpen(false),
                                                                    className: "rounded-xl border border-white/10 bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700",
                                                                    children: "Close"
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 629,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, void 0, true, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 612,
                                                            columnNumber: 23
                                                        }, ("TURBOPACK compile-time value", void 0))
                                                    ]
                                                }, void 0, true, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 602,
                                                    columnNumber: 21
                                                }, ("TURBOPACK compile-time value", void 0)),
                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                    className: "p-6 space-y-6 max-h-[75vh] overflow-y-auto pr-2",
                                                    children: [
                                                        !toolDrilldown && toolLoading && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                            className: "text-slate-400 text-sm",
                                                            children: "Loading drilldown…"
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 639,
                                                            columnNumber: 57
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        !toolDrilldown && toolError && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                            className: "text-rose-400 text-sm",
                                                            children: toolError
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 640,
                                                            columnNumber: 55
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        toolDrilldown && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(__TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["Fragment"], {
                                                            children: [
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "grid gap-4 sm:grid-cols-2 lg:grid-cols-4",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                                            label: "Events",
                                                                            value: formatNumber(toolDrilldown.summary.events)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 645,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                                            label: "Users",
                                                                            value: formatNumber(toolDrilldown.summary.uniqueUsers)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 646,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                                            label: "Sessions",
                                                                            value: formatNumber(toolDrilldown.summary.uniqueSessions)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 647,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                                            label: "Countries",
                                                                            value: formatNumber(toolDrilldown.summary.countries)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 648,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 644,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "grid gap-6 lg:grid-cols-2",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                            className: "rounded-xl border border-white/5 bg-slate-800/60 p-4",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h4", {
                                                                                    className: "text-sm font-semibold mb-2",
                                                                                    children: "Top Countries"
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 653,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                    className: "space-y-2 max-h-64 overflow-y-auto pr-1",
                                                                                    children: toolDrilldown.topCountries.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                        className: "text-slate-500 text-sm",
                                                                                        children: "No data"
                                                                                    }, void 0, false, {
                                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                                        lineNumber: 656,
                                                                                        columnNumber: 35
                                                                                    }, ("TURBOPACK compile-time value", void 0)) : toolDrilldown.topCountries.map((c)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                            className: "flex items-center justify-between rounded-lg border border-white/5 bg-slate-900/50 px-3 py-2",
                                                                                            children: [
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-sm",
                                                                                                    children: c.country
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 660,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-xs font-semibold",
                                                                                                    children: formatNumber(c.events)
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 661,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                                            ]
                                                                                        }, c.country, true, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 659,
                                                                                            columnNumber: 37
                                                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 654,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 652,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                            className: "rounded-xl border border-white/5 bg-slate-800/60 p-4",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h4", {
                                                                                    className: "text-sm font-semibold mb-2",
                                                                                    children: "Top Cities"
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 669,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                    className: "space-y-2 max-h-64 overflow-y-auto pr-1",
                                                                                    children: toolDrilldown.topCities.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                        className: "text-slate-500 text-sm",
                                                                                        children: "No data"
                                                                                    }, void 0, false, {
                                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                                        lineNumber: 672,
                                                                                        columnNumber: 35
                                                                                    }, ("TURBOPACK compile-time value", void 0)) : toolDrilldown.topCities.map((c)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                            className: "flex items-center justify-between rounded-lg border border-white/5 bg-slate-900/50 px-3 py-2",
                                                                                            children: [
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-sm",
                                                                                                    children: [
                                                                                                        c.city,
                                                                                                        ", ",
                                                                                                        c.country
                                                                                                    ]
                                                                                                }, void 0, true, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 676,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-xs font-semibold",
                                                                                                    children: formatNumber(c.events)
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 679,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                                            ]
                                                                                        }, `${c.country}-${c.city}`, true, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 675,
                                                                                            columnNumber: 37
                                                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 670,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 668,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 651,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "grid gap-6 lg:grid-cols-2",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                            className: "rounded-xl border border-white/5 bg-slate-800/60 p-4",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h4", {
                                                                                    className: "text-sm font-semibold mb-2",
                                                                                    children: "Daily Usage"
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 689,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                    className: "space-y-3 max-h-64 overflow-y-auto pr-1",
                                                                                    children: toolDrilldown.daily.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                        className: "text-slate-500 text-sm",
                                                                                        children: "No data"
                                                                                    }, void 0, false, {
                                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                                        lineNumber: 692,
                                                                                        columnNumber: 35
                                                                                    }, ("TURBOPACK compile-time value", void 0)) : toolDrilldown.daily.map((d)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                            className: "flex items-center justify-between text-sm",
                                                                                            children: [
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-slate-300",
                                                                                                    children: d.date
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 696,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "font-semibold",
                                                                                                    children: formatNumber(d.events)
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 697,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                                            ]
                                                                                        }, d.date, true, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 695,
                                                                                            columnNumber: 37
                                                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 690,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 688,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                            className: "rounded-xl border border-white/5 bg-slate-800/60 p-4",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h4", {
                                                                                    className: "text-sm font-semibold mb-2",
                                                                                    children: "Country Series"
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 705,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                    className: "space-y-2 max-h-64 overflow-y-auto pr-1",
                                                                                    children: toolDrilldown.countrySeries.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                        className: "text-slate-500 text-sm",
                                                                                        children: "No data"
                                                                                    }, void 0, false, {
                                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                                        lineNumber: 708,
                                                                                        columnNumber: 35
                                                                                    }, ("TURBOPACK compile-time value", void 0)) : toolDrilldown.countrySeries.map((series)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                            className: "rounded-lg border border-white/5 bg-slate-900/50 p-3",
                                                                                            children: [
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                                    className: "text-sm font-semibold",
                                                                                                    children: series.country
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 712,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                                    className: "mt-2 space-y-1 text-xs text-slate-400",
                                                                                                    children: series.points.map((point)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                                            className: "flex justify-between",
                                                                                                            children: [
                                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                                                                    children: point.date
                                                                                                                }, void 0, false, {
                                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                                    lineNumber: 716,
                                                                                                                    columnNumber: 45
                                                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                                                                    className: "font-semibold text-slate-200",
                                                                                                                    children: formatNumber(point.events)
                                                                                                                }, void 0, false, {
                                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                                    lineNumber: 717,
                                                                                                                    columnNumber: 45
                                                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                                                            ]
                                                                                                        }, point.date, true, {
                                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                                            lineNumber: 715,
                                                                                                            columnNumber: 43
                                                                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                                                                }, void 0, false, {
                                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                                    lineNumber: 713,
                                                                                                    columnNumber: 39
                                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                                            ]
                                                                                        }, series.country, true, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 711,
                                                                                            columnNumber: 37
                                                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 706,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 704,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 687,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, void 0, true)
                                                    ]
                                                }, void 0, true, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 638,
                                                    columnNumber: 21
                                                }, ("TURBOPACK compile-time value", void 0))
                                            ]
                                        }, void 0, true, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 601,
                                            columnNumber: 19
                                        }, ("TURBOPACK compile-time value", void 0))
                                    }, void 0, false, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 600,
                                        columnNumber: 17
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 551,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0)),
                            activeTab === 'feedbacks' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "space-y-6",
                                children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                    className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                    children: [
                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                            className: "text-xl font-semibold mb-4",
                                            children: "All Feedbacks"
                                        }, void 0, false, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 740,
                                            columnNumber: 17
                                        }, ("TURBOPACK compile-time value", void 0)),
                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                            className: "flex gap-2 mb-4",
                                            children: [
                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                    onClick: ()=>setFeedbackTypeFilter(null),
                                                    className: `px-4 py-2 rounded-full text-sm font-medium ${feedbackTypeFilter === null ? 'bg-indigo-500 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`,
                                                    children: "All"
                                                }, void 0, false, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 744,
                                                    columnNumber: 19
                                                }, ("TURBOPACK compile-time value", void 0)),
                                                feedbackTypes.map((type)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                        onClick: ()=>setFeedbackTypeFilter(type),
                                                        className: `px-4 py-2 rounded-full text-sm font-medium capitalize ${feedbackTypeFilter === type ? 'bg-indigo-500 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`,
                                                        children: type
                                                    }, type, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 755,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0)))
                                            ]
                                        }, void 0, true, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 743,
                                            columnNumber: 17
                                        }, ("TURBOPACK compile-time value", void 0)),
                                        feedbacksLoading ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                            className: "text-slate-400",
                                            children: "Loading feedbacks..."
                                        }, void 0, false, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 770,
                                            columnNumber: 19
                                        }, ("TURBOPACK compile-time value", void 0)) : filteredFeedbacks.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                            className: "text-slate-400",
                                            children: "No feedbacks found"
                                        }, void 0, false, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 772,
                                            columnNumber: 19
                                        }, ("TURBOPACK compile-time value", void 0)) : /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                            className: "space-y-4",
                                            children: feedbacksByTool.map((group)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                    className: "rounded-xl border border-white/5 bg-slate-800/50 p-4",
                                                    children: [
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                            className: "flex items-center justify-between mb-3",
                                                            children: [
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                            className: "font-semibold text-indigo-100 text-lg",
                                                                            children: group.toolName
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 779,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                            className: "text-xs text-slate-400",
                                                                            children: [
                                                                                group.feedbacks.length,
                                                                                " feedback(s)"
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 780,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 778,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                    className: "text-xs rounded-full bg-slate-700 px-3 py-1 text-slate-200",
                                                                    children: group.feedbacks.length
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 782,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, void 0, true, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 777,
                                                            columnNumber: 25
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                            className: "space-y-3",
                                                            children: group.feedbacks.map((feedback)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "rounded-lg border border-white/5 bg-slate-900/60 p-4 space-y-2",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                            className: "flex items-start justify-between gap-3",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                                    className: "min-w-0",
                                                                                    children: [
                                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                            className: "font-semibold text-indigo-100 text-base truncate",
                                                                                            children: feedback.toolName || 'Unknown Tool'
                                                                                        }, void 0, false, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 792,
                                                                                            columnNumber: 35
                                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                            className: "text-xs text-slate-400 mt-1 truncate",
                                                                                            children: formatDateTime(feedback.submittedAt)
                                                                                        }, void 0, false, {
                                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                                            lineNumber: 795,
                                                                                            columnNumber: 35
                                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                                    ]
                                                                                }, void 0, true, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 791,
                                                                                    columnNumber: 33
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                                    className: "text-xs rounded-full bg-slate-800 px-3 py-1 capitalize text-slate-200 shrink-0",
                                                                                    children: feedback.type
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 799,
                                                                                    columnNumber: 33
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 790,
                                                                            columnNumber: 31
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                            className: "text-sm text-slate-200 whitespace-pre-line",
                                                                            children: feedback.message
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 804,
                                                                            columnNumber: 31
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        feedback.metadata && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("details", {
                                                                            className: "rounded border border-white/5 bg-slate-950/60",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("summary", {
                                                                                    className: "cursor-pointer px-3 py-2 text-xs text-slate-300",
                                                                                    children: "Tool Results"
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 808,
                                                                                    columnNumber: 35
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("pre", {
                                                                                    className: "px-3 py-2 text-xs text-slate-200 overflow-x-auto",
                                                                                    children: JSON.stringify(feedback.metadata, null, 2)
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 811,
                                                                                    columnNumber: 35
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 807,
                                                                            columnNumber: 33
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, feedback.id, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 789,
                                                                    columnNumber: 29
                                                                }, ("TURBOPACK compile-time value", void 0)))
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 787,
                                                            columnNumber: 25
                                                        }, ("TURBOPACK compile-time value", void 0))
                                                    ]
                                                }, group.toolId, true, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 776,
                                                    columnNumber: 23
                                                }, ("TURBOPACK compile-time value", void 0)))
                                        }, void 0, false, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 774,
                                            columnNumber: 19
                                        }, ("TURBOPACK compile-time value", void 0))
                                    ]
                                }, void 0, true, {
                                    fileName: "[project]/pages/admin/index.tsx",
                                    lineNumber: 739,
                                    columnNumber: 15
                                }, ("TURBOPACK compile-time value", void 0))
                            }, void 0, false, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 738,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0)),
                            activeTab === 'announcements' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "space-y-6",
                                children: [
                                    announcementToCreate && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h3", {
                                                className: "text-lg font-semibold mb-4",
                                                children: "Create New Announcement"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 833,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "space-y-4",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("label", {
                                                                className: "block text-sm font-medium text-slate-300 mb-2",
                                                                children: "Title *"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 836,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("input", {
                                                                type: "text",
                                                                placeholder: "Announcement title...",
                                                                value: newAnnouncementForm.title,
                                                                onChange: (e)=>setNewAnnouncementForm({
                                                                        ...newAnnouncementForm,
                                                                        title: e.target.value
                                                                    }),
                                                                className: "w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-2 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 837,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 835,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("label", {
                                                                className: "block text-sm font-medium text-slate-300 mb-2",
                                                                children: "Content"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 848,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("textarea", {
                                                                placeholder: "Announcement content...",
                                                                value: newAnnouncementForm.content,
                                                                onChange: (e)=>setNewAnnouncementForm({
                                                                        ...newAnnouncementForm,
                                                                        content: e.target.value
                                                                    }),
                                                                rows: 4,
                                                                className: "w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-2 text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 849,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 847,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "grid grid-cols-2 gap-4",
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("label", {
                                                                        className: "block text-sm font-medium text-slate-300 mb-2",
                                                                        children: "Severity"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 861,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("select", {
                                                                        value: newAnnouncementForm.severity,
                                                                        onChange: (e)=>setNewAnnouncementForm({
                                                                                ...newAnnouncementForm,
                                                                                severity: e.target.value
                                                                            }),
                                                                        className: "w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-2 text-white focus:border-indigo-500 focus:outline-none",
                                                                        children: [
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("option", {
                                                                                value: "info",
                                                                                children: "Info"
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 872,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("option", {
                                                                                value: "warning",
                                                                                children: "Warning"
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 873,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("option", {
                                                                                value: "critical",
                                                                                children: "Critical"
                                                                            }, void 0, false, {
                                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                                lineNumber: 874,
                                                                                columnNumber: 27
                                                                            }, ("TURBOPACK compile-time value", void 0))
                                                                        ]
                                                                    }, void 0, true, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 862,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 860,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("label", {
                                                                        className: "block text-sm font-medium text-slate-300 mb-2",
                                                                        children: "Expires At (Optional)"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 878,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("input", {
                                                                        type: "datetime-local",
                                                                        value: newAnnouncementForm.expiresAt,
                                                                        onChange: (e)=>setNewAnnouncementForm({
                                                                                ...newAnnouncementForm,
                                                                                expiresAt: e.target.value
                                                                            }),
                                                                        className: "w-full bg-slate-800 border border-white/10 rounded-lg px-4 py-2 text-white focus:border-indigo-500 focus:outline-none"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 879,
                                                                        columnNumber: 25
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 877,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 859,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "flex gap-3",
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                                onClick: handleCreateAnnouncement,
                                                                className: "bg-indigo-500 hover:bg-indigo-600 px-6 py-2 rounded-lg text-sm font-medium text-white",
                                                                children: "Create Announcement"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 893,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                                onClick: ()=>{
                                                                    setAnnouncementToCreate(false);
                                                                    setNewAnnouncementForm({
                                                                        title: '',
                                                                        content: '',
                                                                        severity: 'info',
                                                                        expiresAt: ''
                                                                    });
                                                                },
                                                                className: "bg-slate-700 hover:bg-slate-600 px-6 py-2 rounded-lg text-sm font-medium text-white",
                                                                children: "Cancel"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 899,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 892,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 834,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 832,
                                        columnNumber: 17
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "flex items-center justify-between mb-4",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                                        className: "text-xl font-semibold",
                                                        children: "Manage Announcements"
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 916,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    !announcementToCreate && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                        onClick: ()=>setAnnouncementToCreate(true),
                                                        className: "bg-indigo-500 hover:bg-indigo-600 px-4 py-2 rounded-lg text-sm font-medium",
                                                        children: "+ New Announcement"
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 918,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 915,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            announcementsLoading ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-slate-400",
                                                children: "Loading announcements..."
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 928,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : announcementsError ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-rose-400",
                                                children: announcementsError
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 930,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : announcements.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-slate-400",
                                                children: "No announcements yet"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 932,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "space-y-3",
                                                children: announcements.map((item)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        className: "rounded-lg border border-white/5 bg-slate-800/50 p-4",
                                                        children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                            className: "flex items-center justify-between",
                                                            children: [
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "flex-1",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                            className: "font-medium",
                                                                            children: item.title
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 939,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                            className: "text-xs text-slate-400 mt-1",
                                                                            children: [
                                                                                "Published: ",
                                                                                formatDateTime(item.publishedAt),
                                                                                " • Expires: ",
                                                                                formatDateTime(item.expiresAt) || 'Never'
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 940,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 938,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                                    className: "flex items-center gap-2",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                                            className: `text-xs px-2 py-1 rounded-full uppercase tracking-wide ${item.severity === 'critical' ? 'bg-rose-500/20 text-rose-200' : item.severity === 'warning' ? 'bg-amber-500/20 text-amber-100' : 'bg-emerald-500/20 text-emerald-100'}`,
                                                                            children: item.severity
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 945,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                                            className: "text-slate-400 hover:text-slate-200 text-sm",
                                                                            children: "Edit"
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 956,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("button", {
                                                                            onClick: ()=>handleDeleteAnnouncement(item.id),
                                                                            className: "text-slate-400 hover:text-rose-400 text-sm",
                                                                            children: "Delete"
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 957,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 944,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, void 0, true, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 937,
                                                            columnNumber: 25
                                                        }, ("TURBOPACK compile-time value", void 0))
                                                    }, item.id, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 936,
                                                        columnNumber: 23
                                                    }, ("TURBOPACK compile-time value", void 0)))
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 934,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 914,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 829,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0)),
                            activeTab === 'users' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                className: "space-y-6",
                                children: [
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                                className: "text-xl font-semibold mb-4",
                                                children: "User Analytics"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 977,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "grid gap-4 md:grid-cols-3",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Total Users",
                                                        value: formatNumber(data?.overview?.totalUsers)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 979,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "Active Users (30d)",
                                                        value: formatNumber(data?.overview?.activeUsers)
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 980,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])(StatCard, {
                                                        label: "New Users",
                                                        value: "TBD"
                                                    }, void 0, false, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 981,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 978,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 976,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                        className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                        children: [
                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "flex items-center justify-between mb-4",
                                                children: [
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                                                className: "text-xl font-semibold",
                                                                children: "All Users"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 988,
                                                                columnNumber: 21
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                className: "text-sm text-slate-400",
                                                                children: "Sorted by most recent sign-up"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 989,
                                                                columnNumber: 21
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 987,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("span", {
                                                        className: "text-xs rounded-full bg-slate-800/80 border border-white/5 px-3 py-1 text-slate-300",
                                                        children: [
                                                            "Showing ",
                                                            users.length,
                                                            " users"
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 991,
                                                        columnNumber: 19
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                ]
                                            }, void 0, true, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 986,
                                                columnNumber: 17
                                            }, ("TURBOPACK compile-time value", void 0)),
                                            usersLoading ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-slate-400",
                                                children: "Loading users…"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 997,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : usersError ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-rose-400",
                                                children: usersError
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 999,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : users.length === 0 ? /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                className: "text-slate-400",
                                                children: "No users found"
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 1001,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0)) : /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                                className: "overflow-x-auto",
                                                children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("table", {
                                                    className: "w-full text-sm",
                                                    children: [
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("thead", {
                                                            children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                                className: "text-left text-slate-400 border-b border-white/5",
                                                                children: [
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "User"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 1007,
                                                                        columnNumber: 27
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Email"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 1008,
                                                                        columnNumber: 27
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Joined"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 1009,
                                                                        columnNumber: 27
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Last Seen"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 1010,
                                                                        columnNumber: 27
                                                                    }, ("TURBOPACK compile-time value", void 0)),
                                                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                        className: "py-2 px-2",
                                                                        children: "Location"
                                                                    }, void 0, false, {
                                                                        fileName: "[project]/pages/admin/index.tsx",
                                                                        lineNumber: 1011,
                                                                        columnNumber: 27
                                                                    }, ("TURBOPACK compile-time value", void 0))
                                                                ]
                                                            }, void 0, true, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1006,
                                                                columnNumber: 25
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 1005,
                                                            columnNumber: 23
                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tbody", {
                                                            children: users.map((u)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                                    className: "border-t border-white/5",
                                                                    children: [
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2",
                                                                            children: [
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                    className: "font-medium text-indigo-100",
                                                                                    children: u.displayName || 'Unnamed'
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 1018,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                                                                                    className: "text-xs text-slate-400 font-mono",
                                                                                    children: u.id
                                                                                }, void 0, false, {
                                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                                    lineNumber: 1021,
                                                                                    columnNumber: 31
                                                                                }, ("TURBOPACK compile-time value", void 0))
                                                                            ]
                                                                        }, void 0, true, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 1017,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-slate-200",
                                                                            children: u.email || '—'
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 1023,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-slate-200 text-xs",
                                                                            children: formatDateTime(u.createdAt)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 1024,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-slate-200 text-xs",
                                                                            children: formatDateTime(u.lastSeenAt)
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 1025,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0)),
                                                                        /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                            className: "py-3 px-2 text-slate-200 text-xs",
                                                                            children: [
                                                                                u.city,
                                                                                u.country
                                                                            ].filter(Boolean).join(', ') || '—'
                                                                        }, void 0, false, {
                                                                            fileName: "[project]/pages/admin/index.tsx",
                                                                            lineNumber: 1026,
                                                                            columnNumber: 29
                                                                        }, ("TURBOPACK compile-time value", void 0))
                                                                    ]
                                                                }, u.id, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1016,
                                                                    columnNumber: 27
                                                                }, ("TURBOPACK compile-time value", void 0)))
                                                        }, void 0, false, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 1014,
                                                            columnNumber: 23
                                                        }, ("TURBOPACK compile-time value", void 0))
                                                    ]
                                                }, void 0, true, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 1004,
                                                    columnNumber: 21
                                                }, ("TURBOPACK compile-time value", void 0))
                                            }, void 0, false, {
                                                fileName: "[project]/pages/admin/index.tsx",
                                                lineNumber: 1003,
                                                columnNumber: 19
                                            }, ("TURBOPACK compile-time value", void 0))
                                        ]
                                    }, void 0, true, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 985,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 975,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0)),
                            activeTab === 'sessions' && /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("section", {
                                className: "bg-slate-900/60 border border-white/5 rounded-2xl p-6",
                                children: [
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("h2", {
                                        className: "text-xl font-semibold mb-4",
                                        children: "Recent Sessions"
                                    }, void 0, false, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 1042,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0)),
                                    /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
                                        className: "overflow-x-auto",
                                        children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("table", {
                                            className: "w-full text-sm",
                                            children: [
                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("thead", {
                                                    children: /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                        className: "text-left text-slate-400 border-b border-white/5",
                                                        children: [
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                className: "py-2 px-2",
                                                                children: "User"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1047,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                className: "py-2 px-2",
                                                                children: "Location"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1048,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                className: "py-2 px-2",
                                                                children: "Version"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1049,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                className: "py-2 px-2",
                                                                children: "Duration"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1050,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0)),
                                                            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("th", {
                                                                className: "py-2 px-2",
                                                                children: "Start Time"
                                                            }, void 0, false, {
                                                                fileName: "[project]/pages/admin/index.tsx",
                                                                lineNumber: 1051,
                                                                columnNumber: 23
                                                            }, ("TURBOPACK compile-time value", void 0))
                                                        ]
                                                    }, void 0, true, {
                                                        fileName: "[project]/pages/admin/index.tsx",
                                                        lineNumber: 1046,
                                                        columnNumber: 21
                                                    }, ("TURBOPACK compile-time value", void 0))
                                                }, void 0, false, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 1045,
                                                    columnNumber: 19
                                                }, ("TURBOPACK compile-time value", void 0)),
                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tbody", {
                                                    children: (data?.recentSessions ?? []).slice(0, 10).map((session)=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("tr", {
                                                            className: "border-t border-white/5",
                                                            children: [
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    className: "py-3 px-2 text-xs",
                                                                    children: session.userId.substring(0, 8)
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1057,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    className: "py-3 px-2 text-xs",
                                                                    children: [
                                                                        session.city,
                                                                        session.country
                                                                    ].filter(Boolean).join(', ') || 'Unknown'
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1058,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    className: "py-3 px-2 text-xs",
                                                                    children: session.appVersion ?? '—'
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1061,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    className: "py-3 px-2 text-xs",
                                                                    children: [
                                                                        (session.durationSeconds / 60).toFixed(1),
                                                                        " min"
                                                                    ]
                                                                }, void 0, true, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1062,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0)),
                                                                /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("td", {
                                                                    className: "py-3 px-2 text-xs text-slate-400",
                                                                    children: formatDateTime(session.startTime)
                                                                }, void 0, false, {
                                                                    fileName: "[project]/pages/admin/index.tsx",
                                                                    lineNumber: 1063,
                                                                    columnNumber: 25
                                                                }, ("TURBOPACK compile-time value", void 0))
                                                            ]
                                                        }, session.id, true, {
                                                            fileName: "[project]/pages/admin/index.tsx",
                                                            lineNumber: 1056,
                                                            columnNumber: 23
                                                        }, ("TURBOPACK compile-time value", void 0)))
                                                }, void 0, false, {
                                                    fileName: "[project]/pages/admin/index.tsx",
                                                    lineNumber: 1054,
                                                    columnNumber: 19
                                                }, ("TURBOPACK compile-time value", void 0))
                                            ]
                                        }, void 0, true, {
                                            fileName: "[project]/pages/admin/index.tsx",
                                            lineNumber: 1044,
                                            columnNumber: 17
                                        }, ("TURBOPACK compile-time value", void 0))
                                    }, void 0, false, {
                                        fileName: "[project]/pages/admin/index.tsx",
                                        lineNumber: 1043,
                                        columnNumber: 15
                                    }, ("TURBOPACK compile-time value", void 0))
                                ]
                            }, void 0, true, {
                                fileName: "[project]/pages/admin/index.tsx",
                                lineNumber: 1041,
                                columnNumber: 13
                            }, ("TURBOPACK compile-time value", void 0))
                        ]
                    }, void 0, true, {
                        fileName: "[project]/pages/admin/index.tsx",
                        lineNumber: 462,
                        columnNumber: 9
                    }, ("TURBOPACK compile-time value", void 0))
                ]
            }, void 0, true, {
                fileName: "[project]/pages/admin/index.tsx",
                lineNumber: 408,
                columnNumber: 7
            }, ("TURBOPACK compile-time value", void 0))
        ]
    }, void 0, true);
};
const StatCard = ({ label, value, isMono = false })=>/*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("div", {
        className: "rounded-2xl border border-white/5 bg-slate-900/60 p-4",
        children: [
            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                className: "text-sm text-slate-400",
                children: label
            }, void 0, false, {
                fileName: "[project]/pages/admin/index.tsx",
                lineNumber: 1079,
                columnNumber: 5
            }, ("TURBOPACK compile-time value", void 0)),
            /*#__PURE__*/ (0, __TURBOPACK__imported__module__$5b$externals$5d2f$react$2f$jsx$2d$dev$2d$runtime__$5b$external$5d$__$28$react$2f$jsx$2d$dev$2d$runtime$2c$__cjs$29$__["jsxDEV"])("p", {
                className: `mt-2 text-2xl font-semibold ${isMono ? 'font-mono text-slate-100' : ''}`,
                children: value
            }, void 0, false, {
                fileName: "[project]/pages/admin/index.tsx",
                lineNumber: 1080,
                columnNumber: 5
            }, ("TURBOPACK compile-time value", void 0))
        ]
    }, void 0, true, {
        fileName: "[project]/pages/admin/index.tsx",
        lineNumber: 1078,
        columnNumber: 3
    }, ("TURBOPACK compile-time value", void 0));
const getServerSideProps = async ({ req })=>{
    const session = (0, __TURBOPACK__imported__module__$5b$project$5d2f$lib$2f$adminAuth$2e$ts__$5b$ssr$5d$__$28$ecmascript$29$__["getAdminSessionFromRequest"])(req);
    if (!session) {
        return {
            redirect: {
                destination: '/admin/login',
                permanent: false
            }
        };
    }
    return {
        props: {
            admin: session
        }
    };
};
const __TURBOPACK__default__export__ = AdminDashboardPage;
}),
"[externals]/next/dist/shared/lib/no-fallback-error.external.js [external] (next/dist/shared/lib/no-fallback-error.external.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/shared/lib/no-fallback-error.external.js", () => require("next/dist/shared/lib/no-fallback-error.external.js"));

module.exports = mod;
}),
];

//# sourceMappingURL=%5Broot-of-the-server%5D__bba80036._.js.map