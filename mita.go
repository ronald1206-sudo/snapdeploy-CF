package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := "7860"
	if envPort := os.Getenv("PORT"); envPort != "" {
		port = envPort
	}

	// 嚴格檢查 /etc/mita/mita.json 配置文件是否存在
	if _, err := os.Stat("/etc/mita/mita.json"); err == nil {
		fmt.Println("【檢查通過】成功找到 /etc/mita/mita.json 配置文件")
	} else {
		fmt.Println("【警告】未在 /etc/mita/ 找到 mita.json，請確認掛載路徑")
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Mita Proxy Service is running cleanly."))
	})

	log.Printf("【啟動成功】服務正在監聽端口 %s...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("【崩潰退出】服務啟動失敗: %v", err)
	}
}
