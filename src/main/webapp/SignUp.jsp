<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Sign Up</title>

<!-- Bootstrap 5 CDN -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Font Awesome Icons -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

</head>
<body class="bg-light">

<div class="container vh-100 d-flex align-items-center justify-content-center">
    <div class="row shadow-lg rounded-4 overflow-hidden bg-white" style="max-width: 900px; width: 100%;">

        <!-- Left Side Form -->
        <div class="col-md-6 p-5">

            <h2 class="mb-4 fw-bold">Sign up</h2>

            <form action="SignUpProcess.jsp" method="post">

                <!-- Name -->
                <div class="mb-3 input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="fa fa-user"></i>
                    </span>
                    <input type="text" class="form-control border-start-0"
                        name="name" placeholder="Your Name" required>
                </div>

                <!-- Email -->
                <div class="mb-3 input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="fa fa-envelope"></i>
                    </span>
                    <input type="email" class="form-control border-start-0"
                        name="email" placeholder="Your Email" required>
                </div>

                <!-- Password -->
                <div class="mb-3 input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="fa fa-lock"></i>
                    </span>
                    <input type="password" class="form-control border-start-0"
                        name="password" placeholder="Password" required>
                </div>

                <!-- Confirm Password -->
                <div class="mb-3 input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="fa fa-lock"></i>
                    </span>
                    <input type="password" class="form-control border-start-0"
                        name="confirmPassword" placeholder="Repeat your password" required>
                </div>
	
				<div class="mb-4">
				    <label>Role</label>
				    <select name="role" class="form-control">
				      <option value="user">User</option>
				      <option value="mentor">Mentor</option>
				    </select>
			  	</div>
               <!--  Checkbox 
                <div class="form-check mb-4">
                    <input class="form-check-input" type="checkbox" required>
                    <label class="form-check-label">
                        I agree all statements in 
                        <a href="#" class="text-decoration-none">Terms of service</a>
                    </label>
                </div> -->

                <!-- Button -->
                <button type="submit" class="btn btn-primary w-100">
                    Register
                </button>

            </form>
        </div>

        <!-- Right Side Image -->
        <div class="col-md-6 d-flex flex-column justify-content-center align-items-center bg-light p-4">
		<img src="assets/img/images/login.png" class="img-fluid w-75 mb-3">
            <a href="SignIn.jsp" class="text-dark text-decoration-underline">
                I am already member
            </a>
        </div>
<div class="container mt-4 text-center">
  <a href="index.jsp" 
     class="btn-getstarted d-inline-flex align-items-center gap-2 px-4 py-2">
     
    <i class="bi bi-arrow-left"></i> Back to Home
  </a>
</div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
