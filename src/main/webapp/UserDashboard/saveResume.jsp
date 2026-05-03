<%@page import="util.DBConnection"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
request.setCharacterEncoding("UTF-8");

Integer uidObj = (Integer) session.getAttribute("userId");
if(uidObj == null){
    response.sendRedirect("SignIn.jsp");
    return;
}

int userId = uidObj;

String name = request.getParameter("name");
String phone = request.getParameter("phone");
String address = request.getParameter("address");
String objective = request.getParameter("objective");
String email = request.getParameter("email");
String linkdin = request.getParameter("linkedin");
String[] degrees = request.getParameterValues("degree");
String[] colleges = request.getParameterValues("college");
String[] years = request.getParameterValues("year");
String[] cgpas = request.getParameterValues("cgpa");

String experienceType = request.getParameter("experienceType");
String company = request.getParameter("company");
String jobRole = request.getParameter("jobRole");
String duration = request.getParameter("duration");
String jobDescription = request.getParameter("jobDescription");

String skills = request.getParameter("skills");
String projects = request.getParameter("projects");
String certifications = request.getParameter("certifications");

String degreeStr = (degrees != null) ? String.join(",", degrees) : "";
String collegeStr = (colleges != null) ? String.join(",", colleges) : "";
String yearStr = (years != null) ? String.join(",", years) : "";
String cgpaStr = (cgpas != null) ? String.join(",", cgpas) : "";

try(Connection con = DBConnection.getConnection()){

    String sql = "INSERT INTO resumes (user_id,name,phone,address,linkedin,objective,degree,college,year,cgpa,experience_type,company,job_role,duration,job_description,skills,projects,certifications,user_email) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

    ps.setInt(1, userId);
    ps.setString(2, name);
    ps.setString(3, phone);
    ps.setString(4, address);
    ps.setString(5, linkdin);
    ps.setString(6, objective);
    ps.setString(7, degreeStr);
    ps.setString(8, collegeStr);
    ps.setString(9, yearStr);
    ps.setString(10, cgpaStr);
    ps.setString(11, experienceType);
    ps.setString(12, company);
    ps.setString(13, jobRole);
    ps.setString(14, duration);
    ps.setString(15, jobDescription);
    ps.setString(16, skills);
    ps.setString(17, projects);
    ps.setString(18, certifications);
    ps.setString(19, email);

    ps.executeUpdate();

    ResultSet rs = ps.getGeneratedKeys();
    int insertedId = 0;
    if(rs.next()) insertedId = rs.getInt(1);

    con.close();

    response.sendRedirect("resumeTemplate.jsp?id=" + insertedId);

}catch(Exception e){
    out.println(e);
}
%>