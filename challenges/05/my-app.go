package main

import (
    "net/http"
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

    // Increment the counter
    go func() {
        for {
            opsProcessed.Inc()
        }
    }()

    // Expose the registered metrics via HTTP
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":2112", nil)
}
