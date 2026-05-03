<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Jobs - ResumeMatch</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="assets/img/project icon.jpeg" rel="icon">
    <style>
        body {
            background-color: #f5f7fa;
        }
        .job-card {
            transition: 0.3s;
        }
        .job-card:hover {
            transform: translateY(-5px);
            box-shadow: 0px 5px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">ResumeMatch</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link active" href="jobs.jsp">Jobs</a></li>
                <li class="nav-item"><a class="nav-link" href="SignIn.jsp">Login</a></li>
                <li class="nav-item"><a class="nav-link" href="SignUp.jsp">Register</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Jobs Section -->
<div class="container mt-5">

    <h2 class="text-center mb-4">Available Job Opportunities</h2>

    <div class="row">

        <!-- Job 1 -->
        <div class="col-md-4">
            <div class="card job-card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Java Developer</h5>
                    <h6 class="card-subtitle mb-2 text-muted">TCS - Pune</h6>
                    <p><strong>Skills:</strong> Java, JSP, MySQL</p>
                    <p><strong>Salary:</strong> 4-6 LPA</p>
                    <p>Looking for a backend Java developer with strong database knowledge.</p>
                    <a href="#" class="btn btn-primary btn-sm">Apply Now</a>
                </div>
            </div>
        </div>

        <!-- Job 2 -->
        <div class="col-md-4">
            <div class="card job-card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Frontend Developer</h5>
                    <h6 class="card-subtitle mb-2 text-muted">Infosys - Bangalore</h6>
                    <p><strong>Skills:</strong> HTML, CSS, JavaScript</p>
                    <p><strong>Salary:</strong> 3-5 LPA</p>
                    <p>Looking for UI developer with responsive design experience.</p>
                    <a href="#" class="btn btn-primary btn-sm">Apply Now</a>
                </div>
            </div>
        </div>

        <!-- Job 3 -->
        <div class="col-md-4">
            <div class="card job-card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Full Stack Developer</h5>
                    <h6 class="card-subtitle mb-2 text-muted">Wipro - Mumbai</h6>
                    <p><strong>Skills:</strong> Java, React, SQL</p>
                    <p><strong>Salary:</strong> 6-8 LPA</p>
                    <p>Full stack developer with experience in backend and frontend.</p>
                    <a href="#" class="btn btn-primary btn-sm">Apply Now</a>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- Footer -->
<footer class="bg-dark text-white text-center p-3 mt-5">
    © 2026 ResumeMatch | All Rights Reserved
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
