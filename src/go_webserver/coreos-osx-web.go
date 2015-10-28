package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    fmt.Println("Serving files in the current directory on port 18000")
    http.Handle("/", http.FileServer(http.Dir(".")))
    err := http.ListenAndServe(":18000", nil)
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}

