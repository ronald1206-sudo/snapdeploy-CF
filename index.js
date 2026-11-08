const net = require('net');

// 從環境變數讀取目標遠端 IP/域名與端口，如果無設定則填入預設值
const PORT = process.env.PORT || 3000;
const TARGET_HOST = process.env.TARGET_HOST || '請填入你遠端VPS的IP或域名';
const TARGET_PORT = parseInt(process.env.TARGET_PORT || '443');

const server = net.createServer((clientSocket) => {
    const targetSocket = new net.Socket();

    // 連接到遠端 VPS
    targetSocket.connect(TARGET_PORT, TARGET_HOST, () => {
        // 雙向管道打通
        clientSocket.pipe(targetSocket);
        targetSocket.pipe(clientSocket);
    });

    // 錯誤處理與保持連線
    clientSocket.on('error', (err) => {
        targetSocket.destroy();
    });

    targetSocket.on('error', (err) => {
        clientSocket.destroy();
    });

    clientSocket.on('close', () => {
        targetSocket.destroy();
    });

    targetSocket.on('close', () => {
        clientSocket.destroy();
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`TCP Forwarder running on port ${PORT}, forwarding to ${TARGET_HOST}:${TARGET_PORT}`);
});
