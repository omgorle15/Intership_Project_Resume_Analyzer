<%@page import="util.DBConnection"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Contact Status</title>
<link href="assets/img/project icon.jpeg" rel="icon">
<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #f8f9fa;
}

.progress {
    height: 6px;
}
</style>

</head>
<body>

<%
String name = request.getParameter("name");
String email = request.getParameter("email");
String subject = request.getParameter("subject");
String message = request.getParameter("message");

boolean status = false;

try(Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO contact_messages(name,email,subject,message) VALUES (?,?,?,?)"
    )) {

    ps.setString(1, name);
    ps.setString(2, email);
    ps.setString(3, subject);
    ps.setString(4, message);

    int i = ps.executeUpdate();

    if(i > 0){
        status = true;
    }

} catch(Exception e) {
    out.println("<h4>Error: " + e.getMessage() + "</h4>");
}
%>

<% if(status) { %>

<div class="alert alert-success shadow-lg rounded-4 p-4 text-center" style="width: 450px;">
    <h4 class="alert-heading"> Message Sent Successfully!</h4>
    <p>Thank you for contacting Job Analyzer.</p>
    <hr>
    <p class="mb-2">Redirecting to Home page in 3 seconds...</p>

    <!-- Progress Bar -->
    <div class="progress mt-3">
        <div id="progressBar" 
             class="progress-bar progress-bar-striped progress-bar-animated bg-success" 
             role="progressbar" 
             style="width: 100%;">
        </div>
    </div>
</div>

<script>
let timeLeft = 3;
let progress = 100;
let intervalTime = 30; // speed of animation
let decreaseAmount = 100 / (3000 / intervalTime);

let timer = setInterval(function() {
    progress -= decreaseAmount;
    document.getElementById("progressBar").style.width = progress + "%";

    if(progress <= 0) {
        clearInterval(timer);
        window.location.href = "index.jsp";
    }
}, intervalTime);
</script>

<% } else { %>

<div class="alert alert-danger shadow-lg rounded-4 p-4 text-center" style="width: 450px;">
    <h4 class="alert-heading"> Message Not Sent!</h4>
    <p>Something went wrong. Please try again.</p>
    <hr>
    <p class="mb-2">Thank You for contact with us</p>

    <!-- Progress Bar -->
    <div class="progress mt-3">
        <div id="progressBar" 
             class="progress-bar progress-bar-striped progress-bar-animated bg-danger" 
             role="progressbar" 
             style="width: 100%;">
        </div>
    </div>
</div>

<script>
let progress = 100;
let intervalTime = 30;
let decreaseAmount = 100 / (3000 / intervalTime);

let timer = setInterval(function() {
    progress -= decreaseAmount;
    document.getElementById("progressBar").style.width = progress + "%";

    if(progress <= 0) {
        clearInterval(timer);
        window.location.href = "Contact.jsp";
    }
}, intervalTime);
</script>

<% } %>

</body>
</html>
