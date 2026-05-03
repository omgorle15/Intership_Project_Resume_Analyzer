<%@ include file="layout.jsp" %>

<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.util.*" %>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%
if (session.getAttribute("userName") == null) {
    response.sendRedirect("SignIn.jsp");
    return;
}

Integer userId = (Integer) session.getAttribute("userId");


if(userId == null){
    response.sendRedirect("SignIn.jsp");
    return;
}
List<String[]> allResumes = new ArrayList<>();
String latestSkills  = "";
String latestJobRole = "";
int    resumeCount   = 0;
int    bookingCount  = 0;
String bookingStatus = "Pending";
List<String[]> recommendedJobs = new ArrayList<>();

try (Connection con = DBConnection.getConnection()) {

    PreparedStatement ps1 = con.prepareStatement(
        "SELECT id, name, degree, job_role, skills FROM resumes WHERE user_id=? ORDER BY id DESC"
    );
    ps1.setInt(1, userId);
    ResultSet rs1 = ps1.executeQuery();
    while (rs1.next()) {
        String rid     = String.valueOf(rs1.getInt("id"));
        String rname   = rs1.getString("name")     != null ? rs1.getString("name")     : "";
        String rdegree = rs1.getString("degree")   != null ? rs1.getString("degree")   : "";
        String rjob    = rs1.getString("job_role") != null ? rs1.getString("job_role") : "";
        String rskills = rs1.getString("skills")   != null ? rs1.getString("skills")   : "";
        rjob = rjob.replaceAll("[^\\x00-\\x7F]+", "").trim();
        allResumes.add(new String[]{rid, rname, rdegree, rjob, rskills});
    }
    resumeCount = allResumes.size();

    if (!allResumes.isEmpty()) {
        latestJobRole = allResumes.get(0)[3];
        latestSkills  = allResumes.get(0)[4];
    }

    try {
        PreparedStatement ps3 = con.prepareStatement(
            "SELECT COUNT(*), MAX(status) FROM mentor_booking WHERE user_id=?"
        );
        ps3.setInt(1, userId);
        ResultSet rs3 = ps3.executeQuery();
        if (rs3.next()) {
            bookingCount = rs3.getInt(1);
            String st = rs3.getString(2);
            if (st != null) bookingStatus = st;
        }
    } catch (Exception ignore) {}

    String skillsLower = latestSkills.toLowerCase();
    String roleLower   = latestJobRole.toLowerCase();

    String[][] jobDefs = {
        {"Java Developer",            "java,spring,hibernate,jdbc,mysql"},
        {"Python Developer",          "python,django,flask,pandas,numpy"},
        {"Web Developer",             "html,css,javascript,react,angular,bootstrap"},
        {"Data Analyst",              "sql,excel,python,tableau,power bi,pandas"},
        {"Backend Engineer",          "java,python,node,spring,api,rest,mysql,mongodb"},
        {"Frontend Developer",        "html,css,javascript,react,vue,angular"},
        {"Full Stack Developer",      "java,javascript,react,spring,mysql,html,css"},
        {"Machine Learning Engineer", "python,tensorflow,keras,scikit,machine learning,deep learning"},
        {"Cloud Engineer",            "aws,azure,gcp,docker,kubernetes,devops"},
        {"Android Developer",         "android,java,kotlin,firebase,xml"},
        {"Software Analyst",          "java,sql,analysis,uml,testing,agile"},
        {"Database Administrator",    "mysql,sql,oracle,mongodb,database,normalization"}
    };

    for (String[] job : jobDefs) {
        String[] keywords = job[1].split(",");
        int matched = 0;
        for (String kw : keywords)
            if (skillsLower.contains(kw.trim()) || roleLower.contains(kw.trim())) matched++;
        if (matched > 0) {
            int score = Math.min(95, 50 + (matched * 45 / keywords.length));
            recommendedJobs.add(new String[]{job[0], String.valueOf(score)});
        }
    }
    recommendedJobs.sort((a, b) -> Integer.parseInt(b[1]) - Integer.parseInt(a[1]));

} catch (Exception e) {
    out.println("<!-- DB Error: " + e.getMessage() + " -->");
}

int resumeScore = 0;
if (!allResumes.isEmpty()) {
    String[] latest = allResumes.get(0);
    if (!latest[1].isEmpty()) resumeScore += 15;
    if (!latest[2].isEmpty()) resumeScore += 20;
    if (!latest[3].isEmpty()) resumeScore += 15;
    if (!latest[4].isEmpty()) resumeScore += 30;
    if (latest[4].split(",").length >= 5) resumeScore += 20;
}
int missingSkills = resumeCount == 0 ? 5 : Math.max(0, 5 - latestSkills.split(",").length);
%>

<% if ("success".equals(request.getParameter("login"))) { %>
<script>
document.addEventListener("DOMContentLoaded", function () {
    Swal.fire({
        icon: 'success',
        title: 'Login Successful!',
        html: 'Welcome back, <b><%= session.getAttribute("userName") %></b>!',
        timer: 3000,
        timerProgressBar: true,
        showConfirmButton: false
    }).then(() => {
        window.history.replaceState({}, document.title, "UserDashboard.jsp");
    });
});
</script>
<% } %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h4 class="fw-bold mb-0">Dashboard</h4>
        <small class="text-muted">Welcome back, <strong><%= session.getAttribute("userName") %></strong></small>
    </div>
    <span class="badge bg-success fs-6"><i class="bi bi-circle-fill me-1" style="font-size:8px"></i>Active</span>
</div>

<!-- Stats Row -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-body text-center py-4">
                <i class="bi bi-speedometer2 fs-1 text-success mb-2 d-block"></i>
                <h6 class="text-muted">Resume Score</h6>
                <% if (resumeCount == 0) { %>
                     <h2 class="fw-bold text-primary"><%= resumeCount %></h2>
                    <small class="text-muted">No resume yet</small>
                <% } else { %>
                    <h2 class="fw-bold <%= resumeScore >= 70 ? "text-success" : resumeScore >= 40 ? "text-warning" : "text-danger" %>">
                        <%= resumeScore %>%
                    </h2>
                    <div class="progress mt-1" style="height:6px">
                        <div class="progress-bar bg-<%= resumeScore >= 70 ? "success" : resumeScore >= 40 ? "warning" : "danger" %>"
                             style="width:<%= resumeScore %>%"></div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-body text-center py-4">
                <i class="bi bi-exclamation-triangle fs-1 text-danger mb-2 d-block"></i>
                <h6 class="text-muted">Missing Skills</h6>
                <% if (resumeCount == 0) { %>
                     <h2 class="fw-bold text-warning"><%= resumeCount %></h2>
                <% } else { %>
                    <h2 class="fw-bold text-danger"><%= missingSkills %></h2>
                    <small class="text-muted">Add more skills to improve</small>
                <% } %>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-body text-center py-4">
                <i class="bi bi-file-earmark-text fs-1 text-primary mb-2 d-block"></i>
                <h6 class="text-muted">My Resumes</h6>
                <h2 class="fw-bold text-primary"><%= resumeCount %></h2>
                <% if (resumeCount > 0) { %>
                    <a href="viewResume.jsp" class="small text-decoration-none text-primary">View all</a>
                <% } else { %>
                    <small class="text-muted">No resumes yet</small>
                <% } %>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-body text-center py-4">
                <i class="bi bi-briefcase fs-1 text-warning mb-2 d-block"></i>
                <h6 class="text-muted">Recommended Jobs</h6>
                <h2 class="fw-bold text-warning"><%= recommendedJobs.size() %></h2>
                <small class="text-muted">Based on your skills</small>
            </div>
        </div>
    </div>
</div>

<!-- Action Cards -->
<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="card shadow-sm card-hover p-4 text-center rounded-4 border-0 h-100">
            <i class="bi bi-file-earmark-plus display-4 text-success"></i>
            <h5 class="mt-3">Create Resume</h5>
            <p class="text-muted">Build a professional resume profile.</p>
            <a href="CreateResume.jsp" class="btn btn-success w-100 rounded-3">Create Now</a>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm card-hover p-4 text-center rounded-4 border-0 h-100">
            <i class="bi bi-upload display-4 text-primary"></i>
            <h5 class="mt-3">Upload & Analyze</h5>
            <p class="text-muted">Upload your existing resume for ATS analysis.</p>
            <a href="UploadResume.jsp" class="btn btn-primary w-100 rounded-3">Upload</a>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm card-hover p-4 text-center rounded-4 border-0 h-100">
            <i class="bi bi-person-lines-fill display-4 text-info"></i>
            <h5 class="mt-3">Book a Mentor</h5>
            <p class="text-muted">Get guidance from an expert mentor.</p>
            <a href="bookMentor.jsp" class="btn btn-info w-100 rounded-3 text-white">Book Now</a>
        </div>
    </div>
</div>

<!-- Bottom Row -->
<div class="row g-3">

    <!-- ALL Resumes Table -->
    <div class="col-md-6">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-header bg-white border-0 pt-3 pb-0 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold mb-0">
                    <i class="bi bi-person-badge me-2 text-success"></i>My Resumes
                    <span class="badge bg-success ms-1"><%= resumeCount %></span>
                </h6>
                <a href="CreateResume.jsp" class="btn btn-sm btn-outline-success rounded-3">
                    <i class="bi bi-plus-lg me-1"></i>New
                </a>
            </div>
            <div class="card-body p-0">
                <% if (allResumes.isEmpty()) { %>
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-file-earmark-x fs-1"></i>
                        <p class="mt-2">No resume found. Create one to get started!</p>
                        <a href="CreateResume.jsp" class="btn btn-sm btn-success">Create Resume</a>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-3">#</th>
                                    <th>Name</th>
                                    <th>Degree</th>
                                    <th>Skills</th>
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (String[] r : allResumes) {
                                String rId     = r[0];
                                String rName   = r[1];
                                String rDegree = r[2];
                                String rSkills = r[4];
                                String[] skillArr = rSkills.isEmpty() ? new String[0] : rSkills.split(",");
                            %>
                                <tr>
                                    <td class="ps-3 text-muted small"><%= rId %></td>
                                    <td class="fw-semibold"><%= rName.isEmpty() ? "—" : rName %></td>
                                    <td class="text-muted small"><%= rDegree.isEmpty() ? "—" : rDegree %></td>
                                    <td>
                                        <% for (int si = 0; si < Math.min(2, skillArr.length); si++) { %>
                                            <span class="badge bg-success-subtle text-success me-1"><%= skillArr[si].trim() %></span>
                                        <% } %>
                                        <% if (skillArr.length > 2) { %>
                                            <span class="badge bg-light text-muted">+<%= skillArr.length - 2 %></span>
                                        <% } %>
                                    </td>
                                    <td class="text-center">
                                        <a href="resumeTemplate.jsp?id=<%= rId %>" class="btn btn-sm btn-outline-success me-1" title="View">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        <a href="updateResume.jsp?id=<%= rId %>" class="btn btn-sm btn-outline-warning" title="Update">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Recommended Jobs -->
    <div class="col-md-6">
        <div class="card shadow-sm rounded-4 border-0 h-100">
            <div class="card-header bg-white border-0 pt-3 pb-0 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold mb-0"><i class="bi bi-briefcase me-2 text-warning"></i>Top Recommended Jobs</h6>
                <a href="Jobs.jsp" class="small text-decoration-none text-warning">View all</a>
            </div>
            <div class="card-body">
                <% if (recommendedJobs.isEmpty()) { %>
                    <div class="text-center py-4 text-muted">
                        <i class="bi bi-search fs-1"></i>
                        <p class="mt-2">Add more skills to your resume to unlock job matches.</p>
                    </div>
                <% } else {
                    int shown = 0;
                    for (String[] job : recommendedJobs) {
                        if (shown++ >= 6) break;
                        int score = Integer.parseInt(job[1]);
                        String color = score >= 80 ? "success" : score >= 65 ? "warning" : "secondary";
                %>
                    <div class="d-flex justify-content-between align-items-center py-2 border-bottom">
                        <div>
                            <i class="bi bi-building me-2 text-muted"></i>
                            <span class="fw-semibold"><%= job[0] %></span>
                        </div>
                        <span class="badge bg-<%= color %>-subtle text-<%= color %> rounded-pill px-3">
                            <%= job[1] %>% match
                        </span>
                    </div>
                <% } } %>
            </div>
        </div>
    </div>

</div>

<!-- Mentor Booking Banner -->
<% if (bookingCount > 0) { %>
<div class="row mt-3">
    <div class="col-12">
        <div class="card shadow-sm rounded-4 border-0 border-start border-4 border-info">
            <div class="card-body py-3">
                <div class="d-flex align-items-center gap-3">
                    <i class="bi bi-calendar-check fs-3 text-info"></i>
                    <div>
                        <h6 class="mb-0 fw-bold">Mentor Bookings</h6>
                        <span class="text-muted">You have <strong><%= bookingCount %></strong> booking(s).
                        Latest status: <span class="badge bg-<%= "Pending".equalsIgnoreCase(bookingStatus) ? "warning" : "Approved".equalsIgnoreCase(bookingStatus) ? "success" : "secondary" %>"><%= bookingStatus %></span></span>
                    </div>
                    <a href="bookMentor.jsp" class="btn btn-sm btn-outline-info ms-auto">Manage</a>
                </div>
            </div>
        </div>
    </div>
</div>
<% } %>

<%@ include file="layoutFooter.jsp" %>