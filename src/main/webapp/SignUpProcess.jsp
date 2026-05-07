<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
String name            = request.getParameter("name");
String email           = request.getParameter("email");
String password        = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String role            = request.getParameter("role");

// ── Password mismatch check ─────────────────────────────────────────────────
if (password == null || !password.equals(confirmPassword)) {
%>
<!DOCTYPE html><html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'warning',
    title: 'Passwords Do Not Match!',
    text: 'Please make sure both passwords are the same.',
    confirmButtonColor: '#d33'
}).then(() => { window.location = "SignUp.jsp"; });
</script></body></html>
<%
    return;
}

try (Connection con = DBConnection.getConnection()) {

    // ✅ FIX: Check if email already exists in DB (covers ALL users, not just admin)
    PreparedStatement checkPs = con.prepareStatement(
        "SELECT id FROM users WHERE email = ?"
    );
    checkPs.setString(1, email);
    ResultSet checkRs = checkPs.executeQuery();

    boolean emailExists = checkRs.next();

    // Also block hardcoded admin email
    if (!emailExists && "omgorle5@gmail.com".equalsIgnoreCase(email)) {
        emailExists = true;
    }

    if (emailExists) {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'error',
    title: 'Email Already Registered!',
    text: 'An account with this email already exists. Please login or use a different email.',
    confirmButtonColor: '#d33',
    confirmButtonText: 'Go to Login'
}).then(() => { window.location = "SignIn.jsp"; });
</script></body></html>
<%
        return;
    }

    // ── Insert new user ─────────────────────────────────────────────────────
    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO users(name, email, password, role, status) VALUES(?, ?, ?, ?, ?)"
    );
    ps.setString(1, name);
    ps.setString(2, email);
    ps.setString(3, password);
    ps.setString(4, role);

    // User = approved directly, Mentor = pending admin approval
    String status = "user".equalsIgnoreCase(role) ? "approved" : "pending";
    ps.setString(5, status);

    int rows = ps.executeUpdate();

    if (rows > 0) {

        if ("user".equalsIgnoreCase(role)) {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'success',
    title: 'Registration Successful!',
    text: 'Welcome! Your account has been created. Please login to continue.',
    confirmButtonColor: '#3085d6',
    confirmButtonText: 'Go to Login'
}).then(() => { window.location = "SignIn.jsp"; });
</script></body></html>
<%
        } else {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'info',
    title: 'Application Submitted!',
    text: 'Your mentor application is pending admin approval. You will be notified once approved.',
    confirmButtonColor: '#3085d6',
    confirmButtonText: 'Go to Login'
}).then(() => { window.location = "SignIn.jsp"; });
</script></body></html>
<%
        }

    } else {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'error',
    title: 'Registration Failed!',
    text: 'Something went wrong. Please try again.',
    confirmButtonColor: '#d33'
}).then(() => { window.location = "SignUp.jsp"; });
</script></body></html>
<%
    }

} catch (Exception e) {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'error',
    title: 'Server Error!',
    text: 'A database error occurred. Please try again.',
    confirmButtonColor: '#d33'
}).then(() => { window.location = "SignUp.jsp"; });
</script></body></html>
<%
}
%>
