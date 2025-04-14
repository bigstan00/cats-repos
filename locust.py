from locust import HttpUser, task, between

class CatsAppUser(HttpUser):
    wait_time = between(1, 3)  # Random wait between requests (1-3 secs)

    @task
    def get_cats(self):
        self.client.get("/cats")  # Replace with your API endpoint

    @task(3)  # 3x more likely than `get_cats`
    def create_cat(self):
        self.client.post("/cats", json={"name": "Whiskers", "age": 2})