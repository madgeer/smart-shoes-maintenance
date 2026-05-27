import React, { useState } from "react";
import { login, register } from "../services/auth";

export const AuthPage = ({ onAuthSuccess }) => {
  const [mode, setMode] = useState("login"); // login / register
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    if (!email || !password || (mode === "register" && !name)) {
      setError("Silakan lengkapi semua data input!");
      setLoading(false);
      return;
    }

    try {
      if (mode === "login") {
        console.log("[AUTH-PAGE] Mencoba login...");
        const data = await login(email, password);
        console.log("[AUTH-PAGE] Login sukses!");
        onAuthSuccess(data.token, data.user || { name: "John Doe" });
      } else {
        console.log("[AUTH-PAGE] Mencoba register...");
        const data = await register(name, email, password);
        console.log("[AUTH-PAGE] Register sukses!");
        // Langsung auto-login setelah sukses register
        onAuthSuccess(data.token, data.user || { name: name });
      }
    } catch (err) {
      console.error("[AUTH-PAGE] Autentikasi gagal:", err);
      const errMsg = err.response?.data?.message || "Email atau password salah. Silakan coba lagi.";
      setError(errMsg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0F0C08] text-white flex items-center justify-center relative overflow-hidden font-sans">
      {/* Efek Pendaran Lingkaran Latar Belakang (Ambient Glowing Circles) */}
      <div className="absolute top-[-10%] left-[-10%] w-[50vw] h-[50vw] rounded-full bg-[#C97B36]/10 blur-[120px] pointer-events-none"></div>
      <div className="absolute bottom-[-10%] right-[-10%] w-[50vw] h-[50vw] rounded-full bg-[#3A2B1C]/20 blur-[120px] pointer-events-none"></div>

      {/* Main Container */}
      <div className="w-full max-w-md p-6 relative z-10">
        
        {/* Logo & Judul Sistem */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-tr from-[#3A2B1C] to-[#C97B36] p-0.5 shadow-lg shadow-[#C97B36]/20 mb-3 animate-pulse">
            <div className="w-full h-full rounded-full bg-[#0F0C08] flex items-center justify-center">
              <svg className="w-8 h-8 text-[#C97B36]" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
          </div>
          <h1 className="text-3xl font-extrabold tracking-wide bg-clip-text text-transparent bg-gradient-to-r from-white via-gray-200 to-[#C97B36]">
            SMART SHOE
          </h1>
          <p className="text-gray-400 text-sm mt-1">Sistem Pemeliharaan Sepatu Pintar IoT</p>
        </div>

        {/* Panel Form Utama (Glassmorphism Card) */}
        <div className="backdrop-blur-md bg-white/[0.03] border border-white/[0.08] rounded-2xl p-8 shadow-2xl relative overflow-hidden">
          {/* Garis Aksen Emas di Bagian Atas Card */}
          <div className="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-[#C97B36] to-transparent"></div>

          {/* Form Switcher Tab */}
          <div className="flex bg-[#0F0C08]/60 p-1 rounded-lg border border-white/[0.05] mb-6">
            <button
              onClick={() => { setMode("login"); setError(""); }}
              className={`flex-1 py-2 text-sm font-semibold rounded-md transition-all duration-300 ${
                mode === "login"
                  ? "bg-[#C97B36] text-white shadow-md shadow-[#C97B36]/10"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              Sign In
            </button>
            <button
              onClick={() => { setMode("register"); setError(""); }}
              className={`flex-1 py-2 text-sm font-semibold rounded-md transition-all duration-300 ${
                mode === "register"
                  ? "bg-[#C97B36] text-white shadow-md shadow-[#C97B36]/10"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              Sign Up
            </button>
          </div>

          {/* Error Alert Message */}
          {error && (
            <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-xs rounded-lg p-3 mb-4 flex items-center gap-2 animate-bounce">
              <svg className="w-4 h-4 shrink-0" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd"></path>
              </svg>
              <span>{error}</span>
            </div>
          )}

          {/* Form Fields */}
          <form onSubmit={handleSubmit} className="space-y-5">
            {mode === "register" && (
              <div className="space-y-1">
                <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block">Nama Lengkap</label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-500">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </span>
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Masukkan nama Anda"
                    className="w-full bg-[#0F0C08]/80 pl-10 pr-4 py-3 rounded-lg border border-white/[0.08] focus:border-[#C97B36] focus:ring-1 focus:ring-[#C97B36] outline-none transition-all duration-300 text-sm placeholder-gray-600"
                    required={mode === "register"}
                  />
                </div>
              </div>
            )}

            <div className="space-y-1">
              <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block">Alamat Email</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-500">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                </span>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@example.com"
                  className="w-full bg-[#0F0C08]/80 pl-10 pr-4 py-3 rounded-lg border border-white/[0.08] focus:border-[#C97B36] focus:ring-1 focus:ring-[#C97B36] outline-none transition-all duration-300 text-sm placeholder-gray-600"
                  required
                />
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex justify-between items-center">
                <label className="text-xs font-semibold text-gray-400 uppercase tracking-wider block">Kata Sandi</label>
              </div>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-500">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </span>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full bg-[#0F0C08]/80 pl-10 pr-4 py-3 rounded-lg border border-white/[0.08] focus:border-[#C97B36] focus:ring-1 focus:ring-[#C97B36] outline-none transition-all duration-300 text-sm placeholder-gray-600"
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full mt-4 py-3 bg-gradient-to-r from-[#C97B36] to-[#E29D52] hover:from-[#E29D52] hover:to-[#C97B36] text-white font-bold text-sm rounded-lg shadow-lg shadow-[#C97B36]/20 hover:shadow-[#C97B36]/30 active:scale-[0.98] transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:pointer-events-none"
            >
              {loading ? (
                <>
                  <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>Memproses...</span>
                </>
              ) : (
                <span>{mode === "login" ? "Sign In" : "Sign Up"}</span>
              )}
            </button>
          </form>
        </div>

        {/* Info Tambahan */}
        <p className="text-center text-xs text-gray-500 mt-6 relative z-10">
          Dengan masuk Anda menyetujui seluruh ketentuan & skema keamanan enkripsi JWT/Bcrypt.
        </p>
      </div>
    </div>
  );
};
