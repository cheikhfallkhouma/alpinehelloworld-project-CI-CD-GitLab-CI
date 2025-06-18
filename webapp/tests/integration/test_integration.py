from webapp.app import app

def test_homepage_status_code():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
