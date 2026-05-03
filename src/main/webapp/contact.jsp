<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Contact - Job Analyzer</title>
<link href="assets/img/project icon.jpeg" rel="icon">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- SAME CSS as index -->
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
    padding: 50px 0;
    text-align: center;
}

.contact-box {
    padding: 35px;
    border-radius: 12px;
    background: #fff;
    box-shadow: 0 8px 25px rgba(0,0,0,0.08);
}

.section-padding {
    padding: 80px 0;
}
</style>

</head>
<body class="index-page">

<!-- ✅ INCLUDE NAVBAR -->
<%@ include file="navbar.jsp" %>

<main class="main">

<!-- ===== Hero Section ===== -->
<section class="hero-section">
    <div class="container">
        <h1 class="fw-bold">Contact Us</h1>
        <p class="mt-2">We would love to hear from you. Reach out anytime!</p>
    </div>
</section>

<!-- ===== Contact Section ===== -->
<section class="section-padding bg-light">
    <div class="container">
        <div class="row g-5">

            <!-- Contact Form -->
            <div class="col-lg-7">
                <div class="contact-box">
                    <h4 class="mb-4 fw-bold text-success">Send Us a Message</h4>

                    <form action="contactSave.jsp" method="post">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Your Name</label>
                                <input type="text" class="form-control" name="name" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Your Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Subject</label>
                            <input type="text" class="form-control" name="subject" required>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">Message</label>
                            <textarea class="form-control" rows="5" name="message" required></textarea>
                        </div>

                        <button type="submit" class="btn btn-success w-100">
                            <i class="bi bi-send"></i> Send Message
                        </button>

                    </form>
                </div>
            </div>

            <!-- Contact Info -->
            <div class="col-lg-5">
                <div class="contact-box mb-4">
                    <h5 class="fw-bold text-success mb-3">Contact Information</h5>
                    <p><i class="bi bi-geo-alt-fill text-success"></i> Rathi Nagar-444602, Amravati</p>
                    <p>Maharashtra, India</p>
                    <p><i class="bi bi-telephone-fill text-success"></i> +91 82455654554</p>
                    <p><i class="bi bi-envelope-fill text-success"></i> Jobanalyzer@gmail.com</p>
                </div>

                <div class="contact-box">
                    <h6 class="fw-bold mb-3 text-success">Follow Us</h6>
                    <a href="#" class="me-3 fs-5 text-success"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="me-3 fs-5 text-success"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="me-3 fs-5 text-success"><i class="bi bi-linkedin"></i></a>
                    <a href="#" class="fs-5 text-success"><i class="bi bi-twitter-x"></i></a>
                </div>
            </div>

        </div>
    </div>
</section>

</main>

<!-- ✅ INCLUDE FOOTER -->
<%@ include file="footer.jsp" %>

<!-- SAME JS as index -->
<script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="assets/vendor/aos/aos.js"></script>
<script src="assets/vendor/glightbox/js/glightbox.min.js"></script>
<script src="assets/vendor/swiper/swiper-bundle.min.js"></script>
<script src="assets/js/main.js"></script>

</body>
</html>