<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <title>How It Works - Job Analyzer</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
<link href="assets/img/project icon.jpeg" rel="icon">
  <!-- SAME CSS as index -->
  <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
  <link href="assets/vendor/aos/aos.css" rel="stylesheet">
  <link href="assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
  <link href="assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">
  <link href="assets/css/main.css" rel="stylesheet">

  <style>
    .step-box {
      background: #fff;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0px 5px 20px rgba(0,0,0,0.05);
      transition: 0.3s;
    }

    .step-box:hover {
      transform: translateY(-8px);
    }

    .step-number {
      font-size: 40px;
      font-weight: bold;
      color: #5fcf80;
    }

    /* ✅ MATCHED HERO STYLE (same as Contact & About) */
    .hero-section {
      background: linear-gradient(to right, #198754, #20c997);
      color: white;
      padding: 80px 0;
      text-align: center;
    }
  </style>
</head>

<body class="index-page">

<!-- ✅ SAME NAVBAR -->
<%@ include file="navbar.jsp" %>

<main class="main">

<!-- ======= Hero Section ======= -->
<section class="hero-section">
  <div class="container text-center">
    <h2>How It Works</h2>
    <p class="mt-3">Simple Steps to Analyze Resume & Get Job Recommendations</p>
  </div>
</section>

<!-- ======= How It Works Section ======= -->
<section class="py-5">
  <div class="container text-center">

    <h2>Our Process</h2>
    <p class="mb-5">Follow these simple steps to boost your career</p>

    <div class="row g-4">

      <div class="col-md-6 col-lg-3">
        <div class="step-box">
          <div class="step-number">01</div>
          <h5 class="mt-3">Upload Resume</h5>
          <p>Upload your resume in PDF or DOC format securely into our system.</p>
        </div>
      </div>

      <div class="col-md-6 col-lg-3">
        <div class="step-box">
          <div class="step-number">02</div>
          <h5 class="mt-3">Resume Analysis</h5>
          <p>The system extracts skills, education and experience from your resume.</p>
        </div>
      </div>

      <div class="col-md-6 col-lg-3">
        <div class="step-box">
          <div class="step-number">03</div>
          <h5 class="mt-3">Profile Evaluation</h5>
          <p>Your resume is evaluated and a score is generated.</p>
        </div>
      </div>

      <div class="col-md-6 col-lg-3">
        <div class="step-box">
          <div class="step-number">04</div>
          <h5 class="mt-3">Job Recommendation</h5>
          <p>Get personalized job suggestions based on your skills.</p>
        </div>
      </div>

    </div>

  </div>
</section>

</main>

<!-- ✅ SAME FOOTER -->
<%@ include file="footer.jsp" %>

<!-- JS (same as index) -->
<script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="assets/vendor/aos/aos.js"></script>
<script src="assets/vendor/glightbox/js/glightbox.min.js"></script>
<script src="assets/vendor/swiper/swiper-bundle.min.js"></script>
<script src="assets/js/main.js"></script>

</body>
</html>