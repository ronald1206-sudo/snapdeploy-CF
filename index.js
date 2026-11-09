const http = require('http');
const net = require('net');

const port = process.env.PORT || 7860;
const uuid = '8a9b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d'; // 必須與你 v2rayN 填寫的一致

const server = http.createServer((req, res) => {
  // 對於普通的 HTTP 訪問，直接返回 200 OK 偽裝成普通網站，避免觸發 403
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Cloud service is online.\n');
});

// 嚴格攔截 WebSocket 升級請求
server.on('upgrade', (req, clientSocket, head) => {
  let remoteSocket = null;
  let isConnected = false;
  let pendingBuffers = [];

  clientSocket.on('data', (message) => {
    if (remoteSocket) {
      if (isConnected) {
        remoteSocket.write(message);
      } else {
        pendingBuffers.push(message);
      }
      return;
    }

    // 第一次握手：校驗 VLESS 協議長度
    if (message.byteLength < 18) {
      clientSocket.destroy();
      return;
    }

    const version = message[0];
    const clientID = message.slice(1, 17).toString('hex');
    const formattedID = `${clientID.slice(0,8)}-${clientID.slice(8,12)}-${clientID.slice(12,16)}-${clientID.slice(16,20)}-${clientID.slice(20)}`;

    // 驗證 UUID
    if (formattedID !== uuid) {
      console.log('UUID mismatch:', formattedID);
      clientSocket.destroy();
      return;
    }

    const optLength = message[17];
    let addressIndex = 18 + optLength;
    const targetPort = message.readUInt16BE(addressIndex + 1);
    const addressType = message[addressIndex + 3]; 
    addressIndex += 4;

    let address = '';
    if (addressType === 1) {
      address = message.slice(addressIndex, addressIndex + 4).join('.');
      addressIndex += 4;
    } else if (addressType === 2) {
      const len = message[addressIndex];
      address = message.slice(addressIndex + 1, addressIndex + 1 + len).toString();
      addressIndex += 1 + len;
    } else if (addressType === 3) {
      address = message.slice(addressIndex, addressIndex + 16).toString('hex').match(/.{1,4}/g).join(':');
      addressIndex += 16;
    } else {
      clientSocket.destroy();
      return;
    }

    const rawTCPBuffer = message.slice(addressIndex);

    // 向客戶端發送 VLESS 握手響應
    const vlessResponse = Buffer.from([version, 0]);
    clientSocket.write(vlessResponse);

    // 建立去往目標網站的 TCP 連接
    console.log(`Connecting to target: ${address}:${targetPort}`);
    remoteSocket = net.connect({ host: address, port: targetPort }, () => {
      isConnected = true;
      if (rawTCPBuffer.length > 0) {
        remoteSocket.write(rawTCPBuffer);
      }
      while (pendingBuffers.length > 0) {
        remoteSocket.write(pendingBuffers.shift());
      }
    });

    remoteSocket.on('data', (data) => {
      if (clientSocket.writable) {
        clientSocket.write(data);
      }
    });

    remoteSocket.on('close', () => clientSocket.destroy());
    remoteSocket.on('error', () => clientSocket.destroy());
  });

  clientSocket.on('error', () => {
    if (remoteSocket) remoteSocket.destroy();
  });
  clientSocket.on('close', () => {
    if (remoteSocket) remoteSocket.destroy();
  });
});

server.listen(port, () => {
  console.log(`VLESS Relay running smoothly on port ${port}`);
});
