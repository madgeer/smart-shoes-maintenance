import React, { useEffect, useState, useRef } from "react";
import {
  Bell,
  Wifi,
  Home,
  Thermometer,
  Droplets,
  Wind,
  Fan,
  Flame,
  ShieldCheck,
  Activity,
  Clock3,
  AlertTriangle,
  Power,
  Timer,
} from "lucide-react";

import { connectSocket } from "./services/socket";
import { login } from "./services/auth";
import { api } from "./services/api";
import { AuthPage } from "./components/AuthPage";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";

function Card({ title, value, status, icon, color }) {
  return (
    <div className="bg-white rounded-3xl p-5 shadow-sm border border-[#eee]">
      <div className={`flex items-center justify-between ${status ? 'mb-4' : ''}`}>
        <div>
          <h3 className="text-sm text-gray-500">{title}</h3>
          <h1 className="text-3xl font-bold mt-1 text-black">{value}</h1>
        </div>

        <div
          className={`w-14 h-14 rounded-2xl flex items-center justify-center ${color}`}
        >
          {icon}
        </div>
      </div>

      {status && (
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-green-500"></div>
          <span className="text-sm text-gray-600">{status}</span>
        </div>
      )}
    </div>
  );
}

function ChartCard({ title, data, dataKey }) {
  return (
    <div className="bg-white rounded-3xl p-5 shadow-sm border border-[#eee]">
      <div className="flex items-center justify-between mb-5">
        <h2 className="font-semibold text-lg text-[#3A2B1C]">{title}</h2>

        <div className="text-xs bg-[#F5F1EA] px-3 py-1 rounded-full text-[#8B5E34]">
          Realtime
        </div>
      </div>

      <div className="w-full h-[260px]">
        <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={0}>
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#ececec" />
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />

            <Line
              type="monotone"
              dataKey={dataKey}
              stroke="#C97B36"
              strokeWidth={3}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

function ControlCard({ title, icon, children }) {
  return (
    <div className="bg-white rounded-3xl p-5 shadow-sm border border-[#eee]">
      <div className="flex items-center gap-3 mb-5">
        <div className="w-12 h-12 rounded-2xl bg-[#F5F1EA] flex items-center justify-center">
          {icon}
        </div>

        <div>
          <h3 className="font-semibold text-[#3A2B1C]">{title}</h3>
          <p className="text-sm text-gray-500">Device Controller</p>
        </div>
      </div>

      {children}
    </div>
  );
}

export default function SmartShoeDryerDashboard() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem("token"));
  const [token, setToken] = useState(localStorage.getItem("token") || "");
  const [userProfile, setUserProfile] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem("user_profile") || "{}");
    } catch {
      return {};
    }
  });

  const [sensorData, setSensorData] = useState({
    temperature: 0,
    humidity: 0,
    gas_level: 0,
  });

  const [tempData, setTempData] = useState([]);
  const [humidityData, setHumidityData] = useState([]);
  const [airData, setAirData] = useState([]);

  const [prediction, setPrediction] = useState(null);
  const [alert, setAlert] = useState(null);
  const [logs, setLogs] = useState([]);
  const [deviceOnline, setDeviceOnline] = useState(false);
  const [controlMode, setControlMode] = useState("auto");
  const [actuators, setActuators] = useState({
    heater: "OFF",
    uv_light: "OFF",
    fan: "OFF",
  });

  const [activeTab, setActiveTab] = useState("Dashboard");

  // State pilihan bahan/sepatu
  const [shoes, setShoes] = useState([]);
  const [selectedShoeId, setSelectedShoeId] = useState(null);
  const selectedShoeIdRef = useRef(null);

  useEffect(() => {
    selectedShoeIdRef.current = selectedShoeId;
  }, [selectedShoeId]);

  const MAX_POINTS = 10;

  const handleActuatorToggle = async (key) => {
    if (controlMode !== "manual") {
      window.alert("Silakan matikan AUTO MODE terlebih dahulu!");
      return;
    }
    const nextVal = actuators[key] === "ON" ? "OFF" : "ON";
    const nextActuators = { ...actuators, [key]: nextVal };
    setActuators(nextActuators);
    try {
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: "manual",
        actuators: nextActuators,
        active_shoe_id: selectedShoeIdRef.current
      });
    } catch (err) {
      console.error("Gagal mengirim komando:", err.message);
    }
  };

  const toggleControlMode = async () => {
    const newMode = controlMode === "auto" ? "manual" : "auto";
    setControlMode(newMode);
    try {
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: newMode,
        actuators: actuators,
        active_shoe_id: selectedShoeIdRef.current
      });
    } catch (err) {
      console.error("Gagal mengubah mode kontrol:", err.message);
    }
  };

  const handleShoeChange = async (shoeId) => {
    setSelectedShoeId(shoeId);
    try {
      // Perbarui active_shoe_id di backend
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: controlMode,
        actuators: actuators,
        active_shoe_id: shoeId
      });

      // Ambil riwayat log sensor terbaru untuk sepatu yang baru terpilih
      const logsResponse = await api.get(`/sensor-logs?shoe_id=${shoeId}`);
      if (logsResponse.data && logsResponse.data.success) {
        const fetchedLogs = logsResponse.data.data;
        const formattedLogs = fetchedLogs.map(item => ({
          date: new Date(item.created_at).toLocaleString(),
          mode: item.drying_status || "AUTO",
          duration: `${Math.round((item.duration_usage || 0) * 60)} min`,
          temp: `${item.temperature.toFixed(1)}°C`,
          result: item.smell_label || "Normal"
        }));
        setLogs(formattedLogs);

        const recentLogs = fetchedLogs.slice(-MAX_POINTS);
        setTempData(recentLogs.map(item => ({
          time: new Date(item.created_at).toLocaleTimeString(),
          value: item.temperature
        })));
        setHumidityData(recentLogs.map(item => ({
          time: new Date(item.created_at).toLocaleTimeString(),
          value: item.humidity
        })));
        setAirData(recentLogs.map(item => ({
          time: new Date(item.created_at).toLocaleTimeString(),
          value: item.gas_level
        })));
      }
    } catch (err) {
      console.error("Gagal mengubah sepatu aktif:", err.message);
    }
  };

  const handleAuthSuccess = (newToken, user) => {
    localStorage.setItem("token", newToken);
    localStorage.setItem("user_profile", JSON.stringify(user));
    setToken(newToken);
    setUserProfile(user);
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user_profile");
    setToken("");
    setUserProfile({});
    setIsAuthenticated(false);
    // Force reload to completely reset websocket/states cleanly
    window.location.reload();
  };

  const sensorDataRef = useRef(sensorData);
  useEffect(() => {
    sensorDataRef.current = sensorData;
  }, [sensorData]);

  useEffect(() => {
    if (!token || !isAuthenticated) return;

    let socket;

    const initSocket = async () => {
      try {
        // Fetch initial data
        try {
          // 1. Ambil daftar sepatu milik user
          const shoesResponse = await api.get("/shoes");
          let activeShoeId = null;
          if (shoesResponse.data && shoesResponse.data.success) {
            const fetchedShoes = shoesResponse.data.data;
            setShoes(fetchedShoes);
            if (fetchedShoes.length > 0) {
              activeShoeId = fetchedShoes[0].id;
            }
          }

          // 2. Ambil data perangkat
          const deviceResponse = await api.get("/devices");
          if (deviceResponse.data && deviceResponse.data.success && deviceResponse.data.data.length > 0) {
            const dev = deviceResponse.data.data[0];
            setDeviceOnline(dev.status === "active" || dev.status === "online");
            if (dev.control_mode) {
              setControlMode(dev.control_mode);
            }
            setActuators({
              heater: dev.heater_state || "OFF",
              uv_light: dev.uv_light_state || "OFF",
              fan: dev.fan_state || "OFF"
            });
            if (dev.active_shoe_id) {
              activeShoeId = dev.active_shoe_id;
            }
          }

          setSelectedShoeId(activeShoeId);

          // 3. Ambil riwayat log sensor untuk sepatu yang aktif
          if (activeShoeId) {
            const logsResponse = await api.get(`/sensor-logs?shoe_id=${activeShoeId}`);
            if (logsResponse.data && logsResponse.data.success) {
              const fetchedLogs = logsResponse.data.data;
              const formattedLogs = fetchedLogs.map(item => ({
                date: new Date(item.created_at).toLocaleString(),
                mode: item.drying_status || "AUTO",
                duration: `${Math.round((item.duration_usage || 0) * 60)} min`,
                temp: `${item.temperature.toFixed(1)}°C`,
                result: item.smell_label || "Normal"
              }));
              setLogs(formattedLogs);

              const recentLogs = fetchedLogs.slice(-MAX_POINTS);
              setTempData(recentLogs.map(item => ({
                time: new Date(item.created_at).toLocaleTimeString(),
                value: item.temperature
              })));
              setHumidityData(recentLogs.map(item => ({
                time: new Date(item.created_at).toLocaleTimeString(),
                value: item.humidity
              })));
              setAirData(recentLogs.map(item => ({
                time: new Date(item.created_at).toLocaleTimeString(),
                value: item.gas_level
              })));
            }
          }

          // 4. Ambil notifikasi terbaru
          const notifResponse = await api.get("/notifications");
          if (notifResponse.data && notifResponse.data.success && notifResponse.data.data.length > 0) {
            const latestNotif = notifResponse.data.data[0];
            setAlert(latestNotif.message);
          }
        } catch (err) {
          console.error("Gagal melakukan load data awal:", err.message);
          if (err.response && err.response.status === 401) {
            console.warn("[AUTH] Token kedaluwarsa atau tidak valid, memaksa logout.");
            handleLogout();
          }
        }

        socket = connectSocket(token);

        socket.on("connect", () => {
          console.log("WEBSOCKET CONNECTED:", socket.id);

          socket.emit("subscribe:device", {
            device_code: "ESP32-SHOE-001",
          });
        });

        socket.on("device:status", (payload) => {
          console.log("DEVICE STATUS UPDATE:", payload);
          if (payload.device_code === "ESP32-SHOE-001") {
            setDeviceOnline(payload.status === "online" || payload.status === "active");
          }
        });

        socket.on("device:command", (payload) => {
          console.log("DEVICE COMMAND UPDATE:", payload);
          if (payload.actuators) {
            setActuators({
              heater: payload.actuators.heater || "OFF",
              uv_light: payload.actuators.uv_light || "OFF",
              fan: payload.actuators.fan || "OFF",
            });
          }
          if (payload.mode) {
            setControlMode(payload.mode);
          }
          if (payload.active_shoe_id && payload.active_shoe_id !== selectedShoeIdRef.current) {
            setSelectedShoeId(payload.active_shoe_id);
          }
        });

        socket.on("sensor:update", (payload) => {
          console.log("SENSOR UPDATE:", payload);
          // Filter sensor update agar hanya memproses sepatu yang sedang aktif
          if (payload.shoe_id && payload.shoe_id !== selectedShoeIdRef.current) {
            console.log("Sensor update diabaikan karena shoe_id berbeda:", payload.shoe_id, selectedShoeIdRef.current);
            return;
          }

          const sensor = payload.data;

          const currentTime =
            new Date().toLocaleTimeString();

          setSensorData({
            temperature: sensor.temperature,
            humidity: sensor.humidity,
            gas_level: sensor.gas_level,
          });

          setTempData((prev) => [
            ...prev.slice(-MAX_POINTS + 1),
            {
              time: currentTime,
              value: sensor.temperature,
            },
          ]);

          setHumidityData((prev) => [
            ...prev.slice(-MAX_POINTS + 1),
            {
              time: currentTime,
              value: sensor.humidity,
            },
          ]);

          setAirData((prev) => [
            ...prev.slice(-MAX_POINTS + 1),
            {
              time: currentTime,
              value: sensor.gas_level,
            },
          ]);
        });

        socket.on("prediction:update", (payload) => {
          console.log("PREDICTION UPDATE:", payload);
          // Filter prediction update agar hanya memproses sepatu yang sedang aktif
          if (payload.shoe_id && payload.shoe_id !== selectedShoeIdRef.current) {
            console.log("Prediction update diabaikan karena shoe_id berbeda:", payload.shoe_id, selectedShoeIdRef.current);
            return;
          }

          setPrediction(payload.prediction);

          if (
            payload.prediction?.smell?.kategori === "Bau"
          ) {
            setAlert(
              "Sepatu terdeteksi bau tinggi. Sistem merekomendasikan UCV sterilization."
            );
          }

          const pred = payload.prediction;
          setLogs((prev) => [
            {
              date: new Date(pred.timestamp || Date.now()).toLocaleString(),
              mode: pred.drying?.drying_status || "AUTO",
              duration: "Live Cycle",
              temp: `${sensorDataRef.current.temperature.toFixed(1)}°C`,
              result: pred.smell?.kategori || "Normal",
            },
            ...prev.slice(0, 19),
          ]);
        });

        socket.on("notification:alert", (payload) => {
          setAlert(payload.message);
        });

      } catch (err) {
        console.error("SOCKET ERROR:", err);
      }
    };

    initSocket();
    return () => {
      if (socket) {
        socket.off("sensor:update");
        socket.off("prediction:update");
        socket.off("notification:alert");
        socket.off("device:status");
        socket.off("device:command");
        socket.disconnect();
      }
    };
  }, [token, isAuthenticated]);

  if (!isAuthenticated) {
    return <AuthPage onAuthSuccess={handleAuthSuccess} />;
  }

  return (
    <div className="min-h-screen bg-[#F5F1EA] flex text-[#3A2B1C]">
      {/* SIDEBAR */}
      <aside className="w-[260px] bg-[#2B1E16] text-white p-6 hidden lg:block">
        <div className="mb-10">
          <h1 className="text-2xl font-bold leading-none">Smart Shoe Maintenance</h1>
          <p className="text-xs text-gray-300 -mt-[25px]">
            System Smart Shoe Maintenance monitoring
          </p>
        </div>

        <nav className="space-y-3">
          {[
            "Dashboard",
            "Monitoring",
            "Kontrol Perangkat",
            "Riwayat",
            "Analisis",
          ].map((item) => (
            <div
              key={item}
              onClick={() => setActiveTab(item)}
              className={`px-4 py-3 rounded-2xl cursor-pointer transition ${activeTab === item
                ? "bg-[#C97B36] text-white"
                : "hover:bg-[#3b2b21] text-gray-300"
                }`}
            >
              {item}
            </div>
          ))}
        </nav>

        <div className="mt-10 bg-[#3A2B1C] rounded-3xl p-5">
          <div className="flex items-center gap-3">
            <Wifi className={deviceOnline ? "text-green-400" : "text-red-400"} />
            <div>
              <h3 className="font-semibold">{deviceOnline ? "Perangkat Terhubung" : "Perangkat Tidak Terhubung"}</h3>
              <p className="text-sm text-gray-400">
                {/*{deviceOnline ? "Device is active" : "Check power / network"}*/}
              </p>
            </div>
          </div>
        </div>
      </aside>

      {/* MAIN */}
      <main className="flex-1 pb-20 lg:pb-0">
        {/* NAVBAR */}
        <header className="bg-white  border-b border-[#ececec] px-6 py-4 flex items-center justify-between">
          <div>
            <h1 className="text-2xl text-black font-bold">Dashboard</h1>
            <p className="text-sm text-gray-500 -mt-[25px]">
              Smart Shoe Maintenance Monitoring
            </p>
          </div>

          <div className="flex items-center gap-5">


            <div className="text-right hidden md:block">
              <h4 className="font-semibold">{userProfile?.name || "User"}</h4>
              <button
                onClick={handleLogout}
                className="text-xs text-red-500 hover:text-red-700 font-semibold underline cursor-pointer"
              >
                Logout
              </button>
            </div>

            <div className="w-11 h-11 rounded-full bg-[#C97B36] flex items-center justify-center font-bold text-white uppercase text-lg">
              {(userProfile?.name || "U").substring(0, 1)}
            </div>
          </div>
        </header>

        <div className="p-6 space-y-6">
          {/* ALERT */}
          {alert && (
            <div className="bg-[#FFF4E5] border border-[#FFB74D] text-[#8B5E34] rounded-2xl p-4 flex items-center gap-3">
              <AlertTriangle />
              <p>{alert}</p>
            </div>
          )}
          {/* BANNER SEPATU AKTIF */}
          {selectedShoeId && (activeTab === "Dashboard" || activeTab === "Device Control") && (
            <div className="bg-white rounded-3xl p-5 border border-[#eee] shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-2xl bg-[#F5F1EA] flex items-center justify-center font-bold text-[#C97B36] text-xl">
                  👟
                </div>
                <div>
                  <h3 className="font-bold text-[#3A2B1C] text-lg">
                    {shoes.find(s => s.id === selectedShoeId)?.shoe_name || "Memuat..."}
                  </h3>
                  <p className="text-sm text-gray-500">
                    Bahan: <span className="font-semibold text-[#C97B36]">{shoes.find(s => s.id === selectedShoeId)?.shoe_material || "Kanvas"}</span>
                  </p>
                </div>
              </div>
              <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
                {/* <div className="bg-[#FFF4E5] px-4 py-2 rounded-2xl text-xs font-semibold text-[#8B5E34] w-full sm:w-auto text-center">
                  ML Input: {shoes.find(s => s.id === selectedShoeId)?.shoe_material === 'Kulit' ? 'Kulit (Pengali Estimasi 0.7x)' : shoes.find(s => s.id === selectedShoeId)?.shoe_material === 'Mesh' ? 'Mesh (Pengali Estimasi 1.5x)' : 'Kanvas (Pengali Estimasi 1.0x)'}
                </div> */}

                {/* Dropdown pemilih sepatu (untuk HP & Desktop) */}
                <div className="flex items-center gap-2 bg-[#F5F1EA] px-3 py-2 rounded-2xl border border-[#ececec] w-full sm:w-auto justify-between sm:justify-start">
                  <span className="text-xs text-gray-600 font-medium whitespace-nowrap">Bahan Sepatu:</span>
                  <select
                    value={selectedShoeId || ""}
                    onChange={(e) => handleShoeChange(parseInt(e.target.value))}
                    className="bg-transparent text-xs font-bold text-[#3A2B1C] focus:outline-none cursor-pointer w-full sm:w-auto"
                  >
                    {shoes.map((shoe) => (
                      <option key={shoe.id} value={shoe.id}>
                        {shoe.shoe_material}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          )}

          {/* TAB 1: DASHBOARD OVERVIEW */}
          {activeTab === "Dashboard" && (
            <section className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
              <Card
                title="Suhu"
                value={`${sensorData.temperature.toFixed(1)}°C`}
                color="bg-orange-100"
                icon={<Thermometer className="text-orange-500" />}
              />

              <Card
                title="Kelembapan"
                value={`${sensorData.humidity.toFixed(1)}% RH`}
                color="bg-blue-100"
                icon={<Droplets className="text-blue-500" />}
              />

              <Card
                title="Kualitas Udara"
                value={`${sensorData.gas_level.toFixed(0)} ppm`}
                color={
                  prediction?.smell?.kategori === "Sangat Bau"
                    ? "bg-red-100"
                    : prediction?.smell?.kategori === "Tidak Bau"
                      ? "bg-green-100"
                      : "bg-yellow-100"
                }
                icon={<Wind className={
                  prediction?.smell?.kategori === "Sangat Bau"
                    ? "text-red-600"
                    : prediction?.smell?.kategori === "Tidak Bau"
                      ? "text-green-600"
                      : "text-yellow-600"
                } />}
              />

              <Card
                title="Status Pengeringan"
                value={prediction?.drying?.drying_status ? (prediction.drying.drying_status.includes("Selesai") ? "SELESAI" : "AKTIF") : "MENUNGGU"}
                color="bg-green-100"
                icon={<Activity className="text-green-600" />}
              />
            </section>
          )}

          {/* ml prediction cards */}
          {activeTab === "Dashboard" && (
            <section className="grid grid-cols-1 md:grid-cols-3 gap-5">
              {/* card klasifikasi kondisi sepatu */}
              <div className="bg-white rounded-3xl p-6 shadow-sm border border-[#eee]">
                <div className="flex items-center gap-3 mb-4">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${prediction?.smell?.kategori === "Sangat Bau" ? "bg-red-100"
                    : prediction?.smell?.kategori === "Tidak Bau" ? "bg-green-100"
                      : "bg-yellow-100"
                    }`}>
                    <Wind className={`${prediction?.smell?.kategori === "Sangat Bau" ? "text-red-500"
                      : prediction?.smell?.kategori === "Tidak Bau" ? "text-green-500"
                        : "text-yellow-500"
                      }`} />
                  </div>
                  <div>
                    <h3 className="text-sm text-gray-500">Kondisi Sepatu</h3>
                  </div>
                </div>

                <div className="flex items-center justify-between mb-3">
                  <span className="text-2xl font-bold text-black">
                    {prediction?.smell?.kategori || "Menunggu..."}
                  </span>
                  <span className={`px-4 py-1.5 rounded-full text-sm font-semibold ${prediction?.smell?.kategori === "Sangat Bau" ? "bg-red-100 text-red-700"
                    : prediction?.smell?.kategori === "Tidak Bau" ? "bg-green-100 text-green-700"
                      : prediction?.smell?.kategori === "Bau Sedang" ? "bg-yellow-100 text-yellow-700"
                        : "bg-gray-100 text-gray-500"
                    }`}>
                    {prediction?.smell?.kategori === "Sangat Bau" ? "⚠ Perlu Tindakan"
                      : prediction?.smell?.kategori === "Bau Sedang" ? "⚠ Perlu Tindakan"
                        : prediction?.smell?.kategori === "Tidak Bau" ? "● Stabil"
                          : "— Idle"}
                  </span>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Kualitas Udara</span>
                    <span className="font-semibold text-[#3A2B1C]">{sensorData.gas_level.toFixed(0)} ppm</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Kelembapan</span>
                    <span className="font-semibold text-[#3A2B1C]">{sensorData.humidity.toFixed(1)}%</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Suhu</span>
                    <span className="font-semibold text-[#3A2B1C]">{sensorData.temperature.toFixed(1)}°C</span>
                  </div>
                </div>
              </div>

              {/* card kondisi kekeringan sepatu */}
              <div className="bg-white rounded-3xl p-6 shadow-sm border border-[#eee]">
                <div className="flex items-center gap-3 mb-4">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${sensorData.humidity <= 15 ? "bg-green-100" : sensorData.humidity <= 60 ? "bg-blue-100" : "bg-red-100"
                    }`}>
                    <Droplets className={`${sensorData.humidity <= 15 ? "text-green-500" : sensorData.humidity <= 60 ? "text-blue-500" : "text-red-500"
                      }`} />
                  </div>
                  <div>
                    <h3 className="text-sm text-gray-500">Kondisi Kekeringan</h3>
                  </div>
                </div>

                <div className="flex items-center justify-between mb-3">
                  <span className="text-2xl font-bold text-black">
                    {sensorData.humidity <= 15 ? "Kering" : sensorData.humidity <= 60 ? "Hampir Kering" : "Basah"}
                  </span>
                  <span className={`px-4 py-1.5 rounded-full text-sm font-semibold ${sensorData.humidity <= 15 ? "bg-green-100 text-green-700" : sensorData.humidity <= 60 ? "bg-blue-100 text-blue-700" : "bg-red-100 text-red-700"
                    }`}>
                    {sensorData.humidity <= 15 ? "✓ Optimal" : sensorData.humidity <= 60 ? "◎ Proses" : "◉ Ekstra Pemanasan"}
                  </span>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Tingkat Kelembapan</span>
                    <span className="font-semibold text-[#3A2B1C]">{sensorData.humidity.toFixed(1)}%</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Suhu Saat Ini</span>
                    <span className="font-semibold text-[#3A2B1C]">{sensorData.temperature.toFixed(1)}°C</span>
                  </div>
                </div>
              </div>

              {/* estimasi waktu pengeringan */}
              <div className="bg-white rounded-3xl p-6 shadow-sm border border-[#eee]">
                <div className="flex items-center gap-3 mb-4">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${prediction?.drying?.drying_status?.includes("Selesai") ? "bg-green-100" : "bg-blue-100"
                    }`}>
                    <Timer className={`${prediction?.drying?.drying_status?.includes("Selesai") ? "text-green-500" : "text-blue-500"
                      }`} />
                  </div>
                  <div>
                    <h3 className="text-sm text-gray-500">Estimasi Waktu Pengeringan</h3>
                  </div>
                </div>

                <div className="flex items-center justify-between mb-3">
                  <span className="text-2xl font-bold text-black">
                    {prediction?.drying?.estimated_drying_time !== undefined
                      ? `${prediction.drying.estimated_drying_time} min`
                      : "— min"}
                  </span>
                  <span className={`px-4 py-1.5 rounded-full text-sm font-semibold ${prediction?.drying?.drying_status?.includes("Selesai") ? "bg-green-100 text-green-700"
                    : prediction?.drying?.drying_status?.includes("sangat basah") ? "bg-red-100 text-red-700"
                      : prediction?.drying?.drying_status?.includes("hampir kering") ? "bg-blue-100 text-blue-700"
                        : "bg-gray-100 text-gray-500"
                    }`}>
                    {prediction?.drying?.drying_status?.includes("Selesai") ? "✓ Selesai"
                      : prediction?.drying?.drying_status?.includes("sangat basah") ? "◉ Sangat Basah"
                        : prediction?.drying?.drying_status?.includes("hampir kering") ? "◎ Hampir Kering"
                          : "— Idle"}
                  </span>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Status</span>
                    <span className="font-semibold text-[#3A2B1C] text-right text-xs max-w-[200px]">
                      {prediction?.drying?.drying_status || "Menunggu data sensor..."}
                    </span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Bahan Sepatu</span>
                    <span className="font-semibold text-[#C97B36]">
                      {shoes.find(s => s.id === selectedShoeId)?.shoe_material || "—"}
                    </span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Sisa Waktu</span>
                    <span className="font-semibold text-[#3A2B1C]">
                      {prediction?.drying?.estimated_drying_time !== undefined
                        ? `${prediction.drying.estimated_drying_time} menit`
                        : "Belum tersedia"}
                    </span>
                  </div>
                </div>
              </div>
            </section>
          )}

          {/* tab2: realtime monitoring charts */}
          {activeTab === "Monitoring" && (
            <section className="grid grid-cols-1 xl:grid-cols-3 gap-5">
              <ChartCard
                title="Suhu"
                data={tempData}
                dataKey="value"
              />

              <ChartCard
                title="Kelembapan"
                data={humidityData}
                dataKey="value"
              />

              <ChartCard
                title="Kualitas Udara"
                data={airData}
                dataKey="value"
              />
            </section>
          )}

          {/* tab3: kontrol perangkat  */}
          {activeTab === "Kontrol Perangkat" && (
            <section className="space-y-6">
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Panel Kontrol Perangkat</h2>

                <button
                  onClick={toggleControlMode}
                  className={`px-5 py-3 rounded-2xl font-bold text-white transition ${controlMode === "auto" ? "bg-[#C97B36]" : "bg-[#3A2B1C]"
                    }`}
                >
                  {controlMode === "auto" ? "Mode Auto Aktif" : "Mode Manual Aktif"}
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                <ControlCard
                  title="Heater (Hairdryer)"
                  icon={<Flame className="text-[#C97B36]" />}
                >
                  <div className="space-y-4">
                    <div className="flex justify-between">
                      <span>Status</span>
                      <span
                        className={`font-semibold ${actuators.heater === "ON" ? "text-green-600" : "text-red-500"
                          }`}
                      >
                        {actuators.heater}
                      </span>
                    </div>

                    <div>
                      <div className="flex justify-between mb-2">
                        <span>Power</span>
                        <span>{actuators.heater === "ON" ? "100%" : "0%"}</span>
                      </div>

                      <div className="h-3 bg-[#eee] rounded-full overflow-hidden">
                        <div
                          className="h-full bg-[#C97B36] transition-all"
                          style={{ width: actuators.heater === "ON" ? "100%" : "0%" }}
                        ></div>
                      </div>
                    </div>

                    <button
                      onClick={() => handleActuatorToggle("heater")}
                      disabled={controlMode !== "manual"}
                      className={`w-full py-3 rounded-2xl text-white transition ${controlMode !== "manual" ? "bg-gray-400 cursor-not-allowed" : actuators.heater === "ON" ? "bg-[#E53935]" : "bg-green-600"
                        }`}
                    >
                      {actuators.heater === "ON" ? "Matikan" : "Nyalakan"}
                    </button>
                  </div>
                </ControlCard>

                <ControlCard
                  title="Exhaust Fan"
                  icon={<Fan className="text-[#C97B36]" />}
                >
                  <div className="space-y-4">
                    <div className="flex justify-between">
                      <span>Status</span>
                      <span
                        className={`font-semibold ${actuators.fan === "ON" ? "text-green-600" : "text-red-500"
                          }`}
                      >
                        {actuators.fan === "ON" ? "AKTIF" : "NONAKTIF"}
                      </span>
                    </div>

                    <div>
                      <div className="flex justify-between mb-2">
                        <span>Kecepatan</span>
                        <span>{actuators.fan === "ON" ? "Maksimal" : "Mati"}</span>
                      </div>

                      <div className="h-3 bg-[#eee] rounded-full overflow-hidden">
                        <div
                          className="h-full bg-[#8B5E34] transition-all"
                          style={{ width: actuators.fan === "ON" ? "100%" : "0%" }}
                        ></div>
                      </div>
                    </div>

                    <button
                      onClick={() => handleActuatorToggle("fan")}
                      disabled={controlMode !== "manual"}
                      className={`w-full py-3 rounded-2xl text-white transition ${controlMode !== "manual" ? "bg-gray-400 cursor-not-allowed" : actuators.fan === "ON" ? "bg-[#E53935]" : "bg-green-600"
                        }`}
                    >
                      {actuators.fan === "ON" ? "Matikan" : "Nyalakan"}
                    </button>
                  </div>
                </ControlCard>

                <ControlCard
                  title="UCV"
                  icon={<ShieldCheck className="text-[#C97B36]" />}
                >
                  <div className="space-y-4">
                    <div className="flex justify-between">
                      <span>Status</span>
                      <span
                        className={`font-semibold ${actuators.uv_light === "ON" ? "text-green-600" : "text-red-500"
                          }`}
                      >
                        {actuators.uv_light === "ON" ? "AKTIF" : "NONAKTIF"}
                      </span>
                    </div>

                    <div className="flex justify-between">
                      <span>Keamanan</span>
                      <span>Otomatis</span>
                    </div>

                    <div className="bg-[#FFF4E5] rounded-2xl p-3 text-sm">
                      Sterilisator UCV membunuh 99% bakteri.
                    </div>

                    <button
                      onClick={() => handleActuatorToggle("uv_light")}
                      disabled={controlMode !== "manual"}
                      className={`w-full py-3 rounded-2xl text-white transition ${controlMode !== "manual" ? "bg-gray-400 cursor-not-allowed" : actuators.uv_light === "ON" ? "bg-[#E53935]" : "bg-green-600"
                        }`}
                    >
                      {actuators.uv_light === "ON" ? "Matikan UCV" : "Nyalakan UCV"}
                    </button>
                  </div>
                </ControlCard>
              </div>
            </section>
          )}

          {/* tab 4: riwayat pengeringan */}
          {activeTab === "Riwayat" && (
            <section className="bg-white rounded-3xl p-5 border border-[#eee] shadow-sm w-full">
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-2xl font-bold text-black">Riwayat Pengeringan</h2>
              </div>

              <div className="overflow-x-auto overflow-y-auto max-h-[60vh] relative">
                <table className="w-full">
                  <thead className="sticky top-0 bg-white z-10 shadow-sm">
                    <tr className="text-left text-gray-500 border-b">
                      <th className="pb-3">Tanggal</th>
                      <th className="pb-3">Mode</th>
                      <th className="pb-3">Durasi</th>
                      <th className="pb-3">Suhu Akhir</th>
                      <th className="pb-3">Hasil</th>
                    </tr>
                  </thead>

                  <tbody>
                    {logs.map((log, index) => (
                      <tr key={index} className="border-b last:border-none">
                        <td className="py-4">{log.date}</td>
                        <td>{log.mode}</td>
                        <td>{log.duration}</td>
                        <td>{log.temp}</td>
                        <td>
                          <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-sm">
                            {log.result}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          )}

          {/* tab 5: ringakasan analisis */}
          {activeTab === "Analisis" && (
            <section className="bg-white rounded-3xl p-5 border border-[#eee] shadow-sm w-full mx-auto ">
              <h2 className="text-2xl font-bold mb-5 text-black">Ringkasan Analisis</h2>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Clock3 className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">Durasi Rata - Rata</h3>
                      <p className="text-2xl font-bold">32 min</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Activity className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">Total Pengeringan Hari Ini</h3>
                      <p className="text-2xl font-bold">12 Siklus</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Wind className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">Rata - Rata Pengurangan Bau</h3>
                      <p className="text-2xl font-bold">68%</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Power className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">Rata - Rata Penggunaan Energi</h3>
                      <p className="text-2xl font-bold">1.8 kWh</p>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          )}
        </div>
      </main>

      {/* mobile bottom navigation bar */}
      <div className="lg:hidden fixed bottom-0 left-0 right-0 bg-[#2B1E16] text-white border-t border-[#3b2b21] z-50 flex justify-around py-3 px-2 shadow-lg">
        {[
          { name: "Dashboard", icon: <Home className="w-5 h-5" /> },
          { name: "Monitoring", icon: <Activity className="w-5 h-5" /> },
          { name: "Kontrol Perangkat", icon: <Power className="w-5 h-5" /> },
          { name: "Riwayat", icon: <Clock3 className="w-5 h-5" /> },
          { name: "Analisis", icon: <Wind className="w-5 h-5" /> },
        ].map((tab) => (
          <button
            key={tab.name}
            onClick={() => setActiveTab(tab.name)}
            className={`flex flex-col items-center gap-1 transition ${activeTab === tab.name ? "text-[#C97B36]" : "text-gray-400 hover:text-gray-200"
              }`}
          >
            {tab.icon}
            <span className="text-xs font-medium">{tab.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
}