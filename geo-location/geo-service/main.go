package main

import (
	"fmt"
	"io"
	"net/http"
	"time"
)

func main() {
	fmt.Println("geo-service is starting!")

	// Set up a ticker to trigger every 10 seconds
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	// Run the main program in an event loop
	for range ticker.C {
		// Perform the HTTP call
		resp, err := http.Get("https://db-ip.com/db/download/ip-to-country-lite")
		if err != nil {
			fmt.Println("Error making HTTP request:", err)
			continue
		}

		// Read the response body
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			fmt.Println("Error reading response body:", err)
			resp.Body.Close() // Close the response body here
			continue
		}
		resp.Body.Close() // Close the response body here

		// Print the response body
		fmt.Println("Response from server:", string(body))
	}
}
