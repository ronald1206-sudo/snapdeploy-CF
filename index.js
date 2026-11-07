const net = require('net');

const LOCAL_PORT = process.env.PORT || 7860;
const TARGET_HOST = process.env.TARGET_HOST;
const TARGET_PORT = parseInt(process.env.TARGET_PORT || '443', 10);

if (!TARGET_HOST) {
  console.error("Error: TARGET_HOST environment variable is not set!");
  process.exit(1);
}

const server = net.createServer((clientSocket) => {
  const remoteSocket = new net.Socket();
  
  // 設定 TCP Keep-Alive 防止連線超時斷開
  clientSocket.setKeepAlive(true, 30000);
  remoteSocket.setKeepAlive(true, 30000);

  remoteSocket.connect(TARGET_PORT, TARGET_HOST, () => {
    clientSocket.pipe(remoteSocket);
    remoteSocket.pipe(clientSocket);
  });

  remoteSocket.on('error', (err) => {
    clientSocket.end();
  });

  clientSocket.on('error', (err) => {
    remoteSocket.end();
  });
});

server.listen(LOCAL_PORT, () => {
  console.log(`TCP Port Forwarder running on port ${LOCAL_PORT}, forwarding -> ${TARGET_HOST}:${TARGET_PORT}`);
});
