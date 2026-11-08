const http = require('http');
const net = require('net');

const PORT = process.env.PORT || 3000;
const TARGET_HOST = process.env.TARGET_HOST || '請填入遠端VPS的IP或域名';
const TARGET_PORT = parseInt(process.env.TARGET_PORT || '443');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Proxy gateway is running\n');
});

// 攔截客戶端的 WebSocket 升級請求，將其轉發為純 TCP 穿透到遠端 VPS
server.on('upgrade', (req, clientSocket, head) => {
    const targetSocket = new net.Socket();

    targetSocket.connect(TARGET_PORT, TARGET_HOST, () => {
        if (head && head.length > 0) {
            targetSocket.write(head);
        }
        clientSocket.pipe(targetSocket);
        targetSocket.pipe(clientSocket);
    });

    clientSocket.on('error', () => targetSocket.destroy());
    targetSocket.on('error', () => clientSocket.destroy());
    clientSocket.on('close', () => targetSocket.destroy());
    targetSocket.on('close', () => targetSocket.destroy());
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`WebSocket Relay running on port ${PORT}, forwarding to ${TARGET_HOST}:${TARGET_PORT}`);
});
