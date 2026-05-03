<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<title>About - Job Analyzer</title>

<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- SAME CSS -->
<link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<link href="assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
<link href="assets/vendor/aos/aos.css" rel="stylesheet">
<link href="assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
<link href="assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">
<link href="assets/css/main.css" rel="stylesheet">

<style>
.hero-section {
    background: linear-gradient(to right, #198754, #20c997);
    color: white;
    padding: 60px 0;
    text-align: center;
}

.feature-box {
    padding: 30px;
    border-radius: 10px;
    background: #fff;
    box-shadow: 0 5px 20px rgba(0,0,0,0.08);
    transition: 0.3s;
}

.feature-box:hover {
    transform: translateY(-8px);
}

.section-padding {
    padding: 70px 0;
}
</style>

</head>

<body class="index-page">

<!-- ✅ NAVBAR -->
<%@ include file="navbar.jsp" %>

<main class="main">

<!-- ✅ MATCHED HERO -->
<section class="hero-section">
  <div class="container text-center">
    <h2>About Job Analyzer</h2>
    <p>Smart Resume Analysis & Career Guidance Platform</p>
  </div>
</section>

<!-- ===== About Content ===== -->
<section class="section-padding bg-light">
    <div class="container">
        <div class="row align-items-center">

            <div class="col-md-6">
                <h2 class="fw-bold mb-4">Who We Are</h2>
                <p>
                    Job Analyzer is a web-based application designed to help job seekers
                    analyze their resumes and receive personalized job recommendations.
                </p>
                <p>
                    In today's competitive job market, many candidates struggle to
                    understand whether their resume matches industry requirements.
                    Our system solves this problem by automatically extracting
                    skills, education, and experience from resumes.
                </p>
                <p>
                    Based on the analysis, the system evaluates the profile and
                    suggests suitable job roles to improve career opportunities.
                </p>
            </div>

            <div class="col-md-6 text-center">
                <img src="assets/img/images/login.jpeg" class="img-fluid rounded shadow">
            </div>

        </div>
    </div>
</section>

<!-- ===== Features ===== -->
<section class="section-padding">
    <div class="container text-center">
        <h2 class="fw-bold mb-5">Key Features</h2>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="feature-box">
                    <h5>Resume Upload</h5>
                    <p>Upload resumes securely in PDF or DOC format.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-box">
                    <h5>Skill Extraction</h5>
                    <p>Automatically extract important skills and qualifications.</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-box">
                    <h5>Job Recommendation</h5>
                    <p>Get personalized job suggestions based on your profile.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ===== Mission ===== -->
<section class="section-padding bg-light text-center">
    <div class="container">
        <h2 class="fw-bold mb-4">Our Mission</h2>
        <p class="lead">
            Our mission is to simplify the job search process by bridging
            the gap between job seekers and employers using smart technology.
        </p>
    </div>
</section>

</main>

<!-- ✅ FOOTER -->
<%@ include file="footer.jsp" %>

<!-- JS -->
<script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="assets/vendor/aos/aos.js"></script>
<script src="assets/vendor/glightbox/js/glightbox.min.js"></script>
<script src="assets/vendor/swiper/swiper-bundle.min.js"></script>
<script src="assets/js/main.js"></script>

</body>
</html>