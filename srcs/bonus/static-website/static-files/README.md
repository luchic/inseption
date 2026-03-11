# Inseption Static Website

This project is a simple static website designed to showcase a portfolio or present a resume. It is built using HTML, CSS, and JavaScript, and can be easily deployed using Docker.

## Project Structure

```
static-website
├── src
│   ├── index.html       # Main HTML document for the website
│   ├── css
│   │   └── style.css    # CSS styles for the website
│   └── js
│       └── main.js      # JavaScript functionality for the website
├── Dockerfile            # Dockerfile for building the Docker image
└── README.md             # Project documentation
```

## Getting Started

To build and run the Docker container for this static website, follow these steps:

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd static-website
   ```

2. **Build the Docker image**:
   ```bash
   docker build -t inseption-static-website .
   ```

3. **Run the Docker container**:
   ```bash
   docker run -d -p 8080:80 inseption-static-website
   ```

4. **Access the website**:
   Open your web browser and navigate to `http://localhost:8080` to view the static website.

## Technologies Used

- HTML
- CSS
- JavaScript
- Docker

## License

This project is licensed under the MIT License. See the LICENSE file for more details.