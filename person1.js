// import { Socket } from "phoenix";
// import WebSocket from "ws";

// console.log("Creating socket...");
// let socket = new Socket("ws://localhost:4000/socket", {
//   transport: WebSocket,
//   params: {
//     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDk5MTAyMjAsImlhdCI6MTc0OTMwNTQyMCwibmJmIjoxNzQ5MzA1NDIwLCJzdWIiOiJlYmYyNzQ1NC03OTNjLTQwMmYtOTM0Zi04ZDNkNGVmZGY1NDkifQ.W99xIJeCKG--pjjTUA8VIDUULwU2U13VH6sgflq1-sU"
//   }
// });

// socket.connect();

// socket.onError(() => {
//   console.log("Socket connection error");
// });

// socket.onClose(() => {
//   console.log("Socket connection closed");
// });

// console.log("Connecting to channel...");
// let channel = socket.channel("chat:b6af1587-cb7c-4f75-ad97-3138ed87d758", {});

// const joinTimeout = setTimeout(() => {
//   console.log("Join timed out (manual timeout)");
//   channel.leave();
//   socket.disconnect();
// }, 5000);

// channel.join()
//   .receive("ok", resp => {
//     clearTimeout(joinTimeout);
//     console.log("Joined successfully", resp);
//   })
//   .receive("error", resp => {
//     clearTimeout(joinTimeout);
//     console.log("Unable to join", resp);
//   })
//   .receive("timeout", () => {
//     clearTimeout(joinTimeout);
//     console.log("Join timed out (timeout event)");
//   });

import { Socket } from "phoenix";
import WebSocket from "ws";
import readline from "readline";

// Setup socket
let startedCLI = false;

console.log("Creating socket...");
let socket = new Socket("ws://localhost:4000/socket", {
  transport: WebSocket,
  params: {
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDk5MTAyMjAsImlhdCI6MTc0OTMwNTQyMCwibmJmIjoxNzQ5MzA1NDIwLCJzdWIiOiJlYmYyNzQ1NC03OTNjLTQwMmYtOTM0Zi04ZDNkNGVmZGY1NDkifQ.W99xIJeCKG--pjjTUA8VIDUULwU2U13VH6sgflq1-sU"
  }
});

socket.connect();

socket.onError(() => console.log("❌ Socket connection error"));
socket.onClose(() => console.log("❌ Socket connection closed"));

console.log("Connecting to channel...");
let channel = socket.channel("chat:b6af1587-cb7c-4f75-ad97-3138ed87d758", {});

channel.join()
  .receive("ok", resp => {
    console.log("✅ Joined successfully", resp);
    if (!startedCLI) {
      startCLI();
      startedCLI = true;
    }
  })

  .receive("error", resp => console.log("❌ Unable to join", resp))
  .receive("timeout", () => console.log("❌ Join timed out"));

channel.on("new_message", payload => {
  console.log("📥 New message:", payload);
});

// Start reading input from CLI
function startCLI() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: '📤 Type your event as JSON and press enter:\n'
  });

  rl.prompt();

  rl.on('line', (line) => {
    try {
      const data = JSON.parse(line.trim());
      if (!data.event || !data.payload) {
        console.log("❗ Format: { \"event\": \"event_name\", \"payload\": { ... } }");
      } else {
        channel.push(data.event, data.payload)
          .receive("ok", resp => console.log("✅ Sent:", resp))
          .receive("error", err => console.log("❌ Error sending:", err));
      }
    } catch (e) {
      console.log("❗ Invalid JSON:", e.message);
    }
    rl.prompt();
  });
}
