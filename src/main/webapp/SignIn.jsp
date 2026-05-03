<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Login</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

</head>
<body class="bg-light">

<div class="container vh-100 d-flex align-items-center justify-content-center">
    
    <div class="card shadow-lg p-5 rounded-4" style="width: 400px;">
        
        <h2 class="text-center mb-4 fw-bold">Login</h2>

        <form action="SignInProcess.jsp" method="post">

            <div class="mb-3 input-group">
                <span class="input-group-text bg-white border-end-0">
                    <i class="fa fa-envelope"></i>
                </span>
                <input type="email" class="form-control border-start-0"
                       name="email" placeholder="Enter Email" required>
            </div>

            <div class="mb-4 input-group">
                <span class="input-group-text bg-white border-end-0">
                    <i class="fa fa-lock"></i>
                </span>
                <input type="password" class="form-control border-start-0"
                       name="password" placeholder="Enter Password" required>
            </div>
			<div class="mb-4">
			    <label>Role</label>
			    <select name="role" class="form-control">
			      <option value="user">User</option>
			      <option value="mentor">Mentor</option>
			    </select>
			  </div>
            <button type="submit" class="btn btn-primary w-100">
                Login
            </button>

            <div class="text-center mt-3">
                Don't have an account?
                <a href="SignUp.jsp" class="text-decoration-none fw-semibold">
                    Register
                </a>
            </div>
		<div class="container mt-4 text-center">
  <a href="index.jsp" 
     class="btn-getstarted d-inline-flex align-items-center gap-2 px-4 py-2">
     
    <i class="bi bi-arrow-left"></i> Back to Home
  </a>
</div>
        </form>
    </div>
</div>

</body>
</html>