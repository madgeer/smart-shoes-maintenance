import { io } from "socket.io-client";

let socket = null;

export const connectSocket = (token) => {
  socket = io("http://localhost:3000", {
    path: "/realtime",
    query: {
      token,
    },
    transports: ["websocket"],
  });

  socket.on("connect", () => {
    console.log("SOCKET CONNECTED:", socket.id);
  });

  socket.on("disconnect", () => {
    console.log("SOCKET DISCONNECTED");
  });

  socket.on("connect_error", (err) => {
    console.error("SOCKET ERROR:", err.message);
  });

  return socket;
};

export const getSocket = () => socket;