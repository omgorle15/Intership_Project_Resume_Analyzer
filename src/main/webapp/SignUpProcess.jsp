<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%
String name = request.getParameter("name");
String email = request.getParameter("email");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String role = request.getParameter("role");

if("omgorle5@gmail.com".equalsIgnoreCase(email)){
%>
<!DOCTYPE html><html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'error',
    title: 'Already Registered!',
    text: 'This email is already registered!',
    confirmButtonColor: '#d33'
}).then(() => { window.location="SignIn.jsp"; });
</script></body></html>
<%  return; }

if(password != null && password.equals(confirmPassword)) {
    try(Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO users(name,email,password,role,status) VALUES(?,?,?,?,?)"
        )) {

        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, role);

        // User = approved directly, Mentor = pending
        String status = "user".equalsIgnoreCase(role) ? "approved" : "pending";
        ps.setString(5, status);

        int i = ps.executeUpdate();

        if(i > 0){
            if("user".equalsIgnoreCase(role)){
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'success',
    title: 'Registration Successful!',
    text: 'Welcome! Please login to continue.',
    confirmButtonColor: '#3085d6',
    confirmButtonText: 'Go to Login'
}).then(() => { window.location="SignIn.jsp"; });
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
}).then(() => { window.location="SignIn.jsp"; });
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
}).then(() => { window.location="SignUp.jsp"; });
</script></body></html>
<%
        }
    } catch(Exception e){
        out.println("Error: " + e.getMessage());
    }
} else {
%>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head><body><script>
Swal.fire({
    icon: 'warning',
    title: 'Passwords Do Not Match!',
    text: 'Please make sure both passwords are same.',
    confirmButtonColor: '#d33'
}).then(() => { window.location="SignUp.jsp"; });
</script></body></html>
<% } %>