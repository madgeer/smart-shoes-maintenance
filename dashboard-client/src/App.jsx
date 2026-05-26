import React, { useEffect, useState, useRef } from "react";
import {
  Bell,
  Wifi,
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
  Zap,
} from "lucide-react";

import { connectSocket } from "./services/socket";
import { login } from "./services/auth";
import { api } from "./services/api";

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
      <div className="flex items-center justify-between mb-4">
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

      <div className="flex items-center gap-2">
        <div className="w-2 h-2 rounded-full bg-green-500"></div>
        <span className="text-sm text-gray-600">{status}</span>
      </div>
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
  const [fanPwm, setFanPwm] = useState(70);
  
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
        actuators: nextActuators
      });
    } catch (err) {
      console.error("Gagal mengirim komando:", err.message);
    }
  };

  const handleFanPwmChange = async (val) => {
    setFanPwm(val);
    if (controlMode !== "manual") return;
    const fanState = val > 0 ? "ON" : "OFF";
    const nextActuators = { ...actuators, fan: fanState };
    setActuators(nextActuators);
    try {
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: "manual",
        actuators: nextActuators
      });
    } catch (err) {
      console.error("Gagal mengirim komando kipas:", err.message);
    }
  };

  const toggleControlMode = async () => {
    const newMode = controlMode === "auto" ? "manual" : "auto";
    setControlMode(newMode);
    try {
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: newMode,
        actuators: actuators
      });
    } catch (err) {
      console.error("Gagal mengubah mode kontrol:", err.message);
    }
  };

  const activatePreset = async (presetName) => {
    let targetActuators = { heater: "OFF", uv_light: "OFF", fan: "OFF" };
    if (presetName === "Quick Dry") {
      targetActuators = { heater: "ON", uv_light: "ON", fan: "ON" };
    } else if (presetName === "Normal Dry") {
      targetActuators = { heater: "ON", uv_light: "OFF", fan: "ON" };
    } else if (presetName === "Sport Shoes") {
      targetActuators = { heater: "OFF", uv_light: "ON", fan: "ON" };
    } else if (presetName === "Leather Mode") {
      targetActuators = { heater: "OFF", uv_light: "OFF", fan: "ON" };
    }

    setControlMode("manual");
    setActuators(targetActuators);
    try {
      await api.post("/devices/ESP32-SHOE-001/commands", {
        mode: "manual",
        actuators: targetActuators
      });
    } catch (err) {
      console.error("Gagal mengaktifkan preset:", err.message);
    }
  };

  const sensorDataRef = useRef(sensorData);
  useEffect(() => {
    sensorDataRef.current = sensorData;
  }, [sensorData]);

  useEffect(() => {
    let socket;

    const initSocket = async () => {
      try {
        const data = await login(
          "johndoe@example.com",
          "password123"
        );

        localStorage.setItem("token", data.token);

        // Fetch initial data
        try {
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
          }

          const logsResponse = await api.get("/sensor-logs?shoe_id=1");
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

          const notifResponse = await api.get("/notifications");
          if (notifResponse.data && notifResponse.data.success && notifResponse.data.data.length > 0) {
            const latestNotif = notifResponse.data.data[0];
            setAlert(latestNotif.message);
          }
        } catch (err) {
          console.error("Gagal melakukan load data awal:", err.message);
        }

        socket = connectSocket(data.token);

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
        });

        socket.on("sensor:update", (payload) => {
          console.log("SENSOR UPDATE:", payload);

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

          setPrediction(payload.prediction);

          if (
            payload.prediction?.smell?.kategori === "Bau"
          ) {
            setAlert(
              "Sepatu terdeteksi bau tinggi. Sistem merekomendasikan UV sterilization."
            );
          }

          // Add to history logs list dynamically using Ref
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
  }, []);

  return (
    <div className="min-h-screen bg-[#F5F1EA] flex text-[#3A2B1C]">
      {/* SIDEBAR */}
      <aside className="w-[260px] bg-[#2B1E16] text-white p-6 hidden lg:block">
        <div className="mb-10">
          <h1 className="text-2xl font-bold">Smart Shoe Dryer</h1>
          <p className="text-sm text-gray-300 mt-1">
            IoT UV Drying System
          </p>
        </div>

        <nav className="space-y-3">
          {[
            "Dashboard",
            "Monitoring",
            "Device Control",
            "History Logs",
            "Analytics",
            "Settings",
          ].map((item, index) => (
            <div
              key={index}
              className={`px-4 py-3 rounded-2xl cursor-pointer transition ${
                index === 0
                  ? "bg-[#C97B36]"
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
              <h3 className="font-semibold">{deviceOnline ? "ESP32 Connected" : "ESP32 Offline"}</h3>
              <p className="text-sm text-gray-400">
                {deviceOnline ? "Device is active" : "Check power / network"}
              </p>
            </div>
          </div>
        </div>
      </aside>

      {/* MAIN */}
      <main className="flex-1">
        {/* NAVBAR */}
        <header className="bg-white border-b border-[#ececec] px-6 py-4 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">Dashboard Overview</h1>
            <p className="text-sm text-gray-500">
              Smart UV Shoe Dryer Monitoring
            </p>
          </div>

          <div className="flex items-center gap-5">
            <div className="text-right hidden md:block">
              <h4 className="font-semibold">21 May 2026</h4>
              <p className="text-sm text-gray-500">11:24 AM</p>
            </div>

            <button className="relative">
              <Bell />
              <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
            </button>

            <div className="w-11 h-11 rounded-full bg-[#C97B36]"></div>
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

          {/* OVERVIEW CARDS */}
          <section className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
            <Card
              title="Temperature"
              value={`${sensorData.temperature.toFixed(1)}°C`}
              status={sensorData.temperature > 40 ? "Heating" : "Stable"}
              color="bg-orange-100"
              icon={<Thermometer className="text-orange-500" />}
            />

            <Card
              title="Humidity"
              value={`${sensorData.humidity.toFixed(1)}% RH`}
              status={sensorData.humidity <= 15 ? "Dry (Optimal)" : "Drying"}
              color="bg-blue-100"
              icon={<Droplets className="text-blue-500" />}
            />

            <Card
              title="Air Quality"
              value={`${sensorData.gas_level.toFixed(0)} ppm`}
              status={prediction?.smell?.kategori || "Normal"}
              color={
                prediction?.smell?.kategori === "Bau"
                  ? "bg-red-100"
                  : prediction?.smell?.kategori === "Wangi"
                  ? "bg-green-100"
                  : "bg-yellow-100"
              }
              icon={<Wind className="text-yellow-600" />}
            />

            <Card
              title="Drying Status"
              value={prediction?.drying?.drying_status ? (prediction.drying.drying_status.includes("Selesai") ? "SELESAI" : "ACTIVE") : "IDLE"}
              status={
                prediction?.drying?.estimated_drying_time !== undefined
                  ? `${prediction.drying.estimated_drying_time} min sisa`
                  : "Optimal"
              }
              color="bg-green-100"
              icon={<Activity className="text-green-600" />}
            />
          </section>

          {/* CHARTS */}
          <section className="grid grid-cols-1 xl:grid-cols-3 gap-5">
            <ChartCard
              title="Temperature Chart"
              data={tempData}
              dataKey="value"
            />

            <ChartCard
              title="Humidity Chart"
              data={humidityData}
              dataKey="value"
            />

            <ChartCard
              title="Air Quality Chart"
              data={airData}
              dataKey="value"
            />
          </section>

          {/* DEVICE CONTROL */}
          <section>
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-2xl font-bold">Device Control Panel</h2>

              <button
                onClick={toggleControlMode}
                className={`px-5 py-3 rounded-2xl font-bold text-white transition ${
                  controlMode === "auto" ? "bg-[#C97B36]" : "bg-[#3A2B1C]"
                }`}
              >
                {controlMode === "auto" ? "Auto Mode Enabled" : "Manual Mode Active"}
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
              <ControlCard
                title="Heater Control"
                icon={<Flame className="text-[#C97B36]" />}
              >
                <div className="space-y-4">
                  <div className="flex justify-between">
                    <span>Status</span>
                    <span
                      className={`font-semibold ${
                        actuators.heater === "ON" ? "text-green-600" : "text-red-500"
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
                    className={`w-full py-3 rounded-2xl text-white transition ${
                      actuators.heater === "ON" ? "bg-[#E53935]" : "bg-green-600"
                    }`}
                  >
                    {actuators.heater === "ON" ? "Turn OFF" : "Turn ON"}
                  </button>
                </div>
              </ControlCard>

              <ControlCard
                title="Fan PWM"
                icon={<Fan className="text-[#C97B36]" />}
              >
                <div className="space-y-4">
                  <div className="flex justify-between">
                    <span>RPM</span>
                    <span>{actuators.fan === "ON" ? `${2000 + Math.round(fanPwm * 5)} RPM` : "0 RPM"}</span>
                  </div>

                  <input
                    type="range"
                    min={0}
                    max={100}
                    value={fanPwm}
                    onChange={(e) => handleFanPwmChange(parseInt(e.target.value))}
                    className="w-full"
                    disabled={controlMode !== "manual"}
                  />

                  <div className="text-center text-sm text-gray-500">
                    PWM Speed {fanPwm}%
                  </div>
                </div>
              </ControlCard>

              <ControlCard
                title="Blower"
                icon={<Wind className="text-[#C97B36]" />}
              >
                <div className="space-y-4">
                  <div className="flex justify-between">
                    <span>Status</span>
                    <span
                      className={`font-semibold ${
                        actuators.fan === "ON" ? "text-green-600" : "text-red-500"
                      }`}
                    >
                      {actuators.fan === "ON" ? "ACTIVE" : "INACTIVE"}
                    </span>
                  </div>

                  <div>
                    <div className="flex justify-between mb-2">
                      <span>Speed</span>
                      <span>{actuators.fan === "ON" ? "Medium" : "Off"}</span>
                    </div>

                    <div className="h-3 bg-[#eee] rounded-full overflow-hidden">
                      <div
                        className="h-full bg-[#8B5E34] transition-all"
                        style={{ width: actuators.fan === "ON" ? "55%" : "0%" }}
                      ></div>
                    </div>
                  </div>

                  <button
                    onClick={() => handleActuatorToggle("fan")}
                    className="w-full py-3 rounded-2xl bg-[#3A2B1C] text-white hover:opacity-90 transition"
                  >
                    Toggle Blower
                  </button>
                </div>
              </ControlCard>

              <ControlCard
                title="UV Sterilizer"
                icon={<ShieldCheck className="text-[#C97B36]" />}
              >
                <div className="space-y-4">
                  <div className="flex justify-between">
                    <span>Status</span>
                    <span
                      className={`font-semibold ${
                        actuators.uv_light === "ON" ? "text-green-600" : "text-red-500"
                      }`}
                    >
                      {actuators.uv_light === "ON" ? "ACTIVE" : "INACTIVE"}
                    </span>
                  </div>

                  <div className="flex justify-between">
                    <span>Safety</span>
                    <span>Auto Enabled</span>
                  </div>

                  <div className="bg-[#FFF4E5] rounded-2xl p-3 text-sm">
                    UV sterilizer kills 99% of bacteria.
                  </div>

                  <button
                    onClick={() => handleActuatorToggle("uv_light")}
                    className={`w-full py-3 rounded-2xl text-white transition ${
                      actuators.uv_light === "ON" ? "bg-[#E53935]" : "bg-green-600"
                    }`}
                  >
                    {actuators.uv_light === "ON" ? "Disable UV" : "Enable UV"}
                  </button>
                </div>
              </ControlCard>
            </div>
          </section>

          {/* PRESET MODES */}
          <section>
            <h2 className="text-2xl font-bold mb-5">
              Drying Preset Modes
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
              {[
                {
                  title: "Quick Dry",
                  desc: "High temperature & fast drying",
                },
                {
                  title: "Normal Dry",
                  desc: "Balanced everyday mode",
                },
                {
                  title: "Sport Shoes",
                  desc: "Odor reduction & UV focus",
                },
                {
                  title: "Leather Mode",
                  desc: "Low temperature safe drying",
                },
              ].map((mode, index) => (
                <div
                  key={index}
                  className="bg-white rounded-3xl p-5 border border-[#eee] shadow-sm"
                >
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="font-bold text-lg">{mode.title}</h3>

                    <Zap className="text-[#C97B36]" />
                  </div>

                  <p className="text-gray-500 text-sm mb-5">
                    {mode.desc}
                  </p>

                  <button
                    onClick={() => activatePreset(mode.title)}
                    className="w-full py-3 rounded-2xl bg-[#F5F1EA] hover:bg-[#C97B36] hover:text-white transition"
                  >
                    Activate
                  </button>
                </div>
              ))}
            </div>
          </section>

          {/* LOGS + ANALYTICS */}
          <section className="grid grid-cols-1 xl:grid-cols-3 gap-5">
            {/* LOGS */}
            <div className="xl:col-span-2 bg-white rounded-3xl p-5 border border-[#eee] shadow-sm">
              <div className="flex items-center justify-between mb-5">
                <h2 className="text-2xl font-bold">
                  Drying History Logs
                </h2>

                <button className="text-[#C97B36]">
                  View All
                </button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="text-left text-gray-500 border-b">
                      <th className="pb-3">Date</th>
                      <th className="pb-3">Mode</th>
                      <th className="pb-3">Duration</th>
                      <th className="pb-3">Final Temp</th>
                      <th className="pb-3">Result</th>
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
            </div>

            {/* ANALYTICS */}
            <div className="bg-white rounded-3xl p-5 border border-[#eee] shadow-sm">
              <h2 className="text-2xl font-bold mb-5">Analytics</h2>

              <div className="space-y-5">
                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Clock3 className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">
                        Avg Duration
                      </h3>
                      <p className="text-2xl font-bold">32 min</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Activity className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">
                        Total Drying Today
                      </h3>
                      <p className="text-2xl font-bold">12 Cycles</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Wind className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">
                        Avg Odor Reduction
                      </h3>
                      <p className="text-2xl font-bold">68%</p>
                    </div>
                  </div>
                </div>

                <div className="bg-[#F5F1EA] rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <Power className="text-[#C97B36]" />
                    <div>
                      <h3 className="text-sm text-gray-500">
                        Energy Usage
                      </h3>
                      <p className="text-2xl font-bold">1.8 kWh</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </main>
    </div>
  );
}