package main

import (
	"log"

	"github.com/nixpig/proglog/internal/server"
)

func main() {
	srv := server.NewHTTPServer("localhost:8080")
	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
