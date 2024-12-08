import json
import time
import random
from datetime import datetime

def generate_log():
    log = {
        "ip": f"{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}",
        "user_id": random.randint(1000, 9999),
        "timestamp": datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ"),
        "method": random.choice(["GET", "POST", "PUT", "DELETE", "PATCH"]),
        "url": f"/course/{random.choice(['python', 'javascript', 'java', 'csharp', 'go', 'ruby'])}",
        "status": random.choice([200, 201, 204, 400, 401, 403, 404, 500]),
        "response_time_ms": random.randint(20, 2000),
        "user_agent": random.choice([
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15",
            "Mozilla/5.0 (iPhone; CPU iPhone OS 14_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36 Edg/89.0.774.50",
            "Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.152 Mobile Safari/537.36"
        ])
    }
    return log

def append_log_to_file(log, filename="/var/log/access.log"):
    with open(filename, "a") as file:
        file.write(json.dumps(log) + "\n")

def main():
    while True:
        log = generate_log()
        append_log_to_file(log)
        sleep_time = random.randint(1, 10)  # Random interval between 1 and 10 seconds
        time.sleep(sleep_time)

if __name__ == "__main__":
    main()
