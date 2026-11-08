const WebSocket = require('ws');
const http = require('http');
const net = require('net');

// 🔑 必須確保這裏的 UUID 同你 v2rayN 填寫的一模一樣！
const uuid = '8a9b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d';
const port = process.env.PORT || 7860;

const server = http.createServer((req, res) => {
  // 普通瀏覽器訪問時安全偽裝，跳轉去 Bing
  res.writeHead(302, { 'Location': 'https://www.bing.com' });
  res.end();
});

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('Client attempting connection...');
  let remoteSocket = null;

  ws.on('message', (message) => {
    // 如果已經建立了 TCP 連接，直接雙向轉發數據
    if (remoteSocket && remoteSocket.writable) {
      remoteSocket.write(message);
      return;
    }

    // 第一次握手：嚴格解析 VLESS 協議
    if (message.byteLength < 18) {
      console.log('Packet too short');
      ws.close();
      return;
    }

    const version = message[0];
    const clientID = message.slice(1, 17).toString('hex');
    const formattedID = `${clientID.slice(0,8)}-${clientID.slice(8,12)}-${clientID.slice(12,16)}-${clientID.slice(16,20)}-${clientID.slice(20)}`;

    // 驗證 UUID 暗號
    if (formattedID !== uuid) {
      console.log('UUID mismatch! Got:', formattedID);
      ws.close();
      return;
    }

    const optLength = message[17];
    let addressIndex = 18 + optLength;
    const cmd = message[addressIndex]; // 1 代表 TCP, 2 代表 UDP
    const targetPort = message.readUInt16BE(addressIndex + 1);
    const addressType = message[addressIndex + 3]; // 1: IPv4, 2: Domain, 3: IPv6
    addressIndex += 4;

    let address = '';
    if (addressType === 1) {
      // IPv4 (4 bytes)
      address = message.slice(addressIndex, addressIndex + 4).join('.');
      addressIndex += 4;
    } else if (addressType === 2) {
      // Domain Name (1 byte length + domain string)
      const len = message[addressIndex];
      address = message.slice(addressIndex + 1, addressIndex + 1 + len).toString();
      addressIndex += 1 + len;
    } else if (addressType === 3) {
      // IPv6 (16 bytes)
      address = message.slice(addressIndex, addressIndex + 16).toString('hex').match(/.{1,4}/g).join(':');
      addressIndex += 16;
    } else {
      console.log('Unsupported address type:', addressType);
      ws.close();
      return;
    }

    const rawTCPBuffer = message.slice(addressIndex);

    // 🚀 【核心修正】向 v2rayN 客戶端發送 VLESS 握手響應（Version: 0, Options length: 0）
    // 冇呢個響應，v2rayN 就會一直卡住並判定真連接為 -1
    const vlessResponse = Buffer.from([version, 0]);
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(vlessResponse);
    }

    // 建立去往目標網站的 TCP 連接
    console.log(`Connecting to remote target: ${address}:${targetPort}`);
    remoteSocket = net.connect({ host: address, port: targetPort }, () => {
      // 連接成功後，將客戶端第一包剩餘數據寫入
      if (rawTCPBuffer.length > 0) remoteSocket.write(rawTCPBuffer);
    });

    remoteSocket.on('data', (data) => {
      if (ws.readyState === WebSocket.OPEN) ws.send(data);
    });

    remoteSocket.on('close', () => ws.close());
    remoteSocket.on('error', (err) => {
      console.log('Target connection error:', err.message);
      ws.close();
    });
  });

  ws.on('close', () => {
    if (remoteSocket) remoteSocket.destroy();
    console.log('Client disconnected');
  });
});

server.listen(port, () => {
  console.log(`VLESS Tunnel Server running on port ${port}`);
});
