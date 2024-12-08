package main

import (
    "log"
    "net/http"
    "os"
    "time"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
    // Create a new counter metric
    opsProcessed := prometheus.NewCounter(prometheus.CounterOpts{
        Name: "myapp_processed_ops_total",
        Help: "The total number of processed operations",
    })

    // Register the metric
    prometheus.MustRegister(opsProcessed)

    // Open log file for appending
    file, err := os.OpenFile("/var/log/my-metrics-app.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Fatalf("Failed to open log file: %v", err)
    }
    defer file.Close()
    logger := log.New(file, "", log.LstdFlags)

    // Increment the counter
    go func() {
        for {
            opsProcessed.Inc()
            timestamp := time.Now().Format(time.RFC3339)
            logger.Printf("Processed operation at %s", timestamp)
            time.Sleep(1 * time.Second) // Adding sleep to avoid busy loop
        }
    }()

    // Expose the registered metrics via HTTP
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":2112", nil)
}
