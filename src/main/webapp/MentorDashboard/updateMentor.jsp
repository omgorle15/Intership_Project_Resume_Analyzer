<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
Integer userId = (Integer) session.getAttribute("userId");
String  role   = (String)  session.getAttribute("userRole");
if (userId == null || !"mentor".equalsIgnoreCase(role)) {
    response.sendRedirect("../SignIn.jsp"); return;
}

// Load existing profile
String existName = "", existBio = "", existPhone = "", existSpec = "";
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT u.name, u.phone, mp.bio, mp.specialization " +
        "FROM users u LEFT JOIN mentor_profile mp ON u.id=mp.user_id WHERE u.id=?"
    );
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        existName  = rs.getString("name")           != null ? rs.getString("name")           : "";
        existPhone = rs.getString("phone")          != null ? rs.getString("phone")          : "";
        existBio   = rs.getString("bio")            != null ? rs.getString("bio")            : "";
        existSpec  = rs.getString("specialization") != null ? rs.getString("specialization") : "";
    }
} catch (Exception e) { e.printStackTrace(); }

String successMsg = request.getParameter("success");
String errorMsg   = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Update Profile</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
body { background: #f4f6f9; }
/* Red border when phone is invalid */
#phoneInput.is-invalid { border-color: #dc3545; }
#phoneInput.is-valid   { border-color: #198754; }
</style>
</head>
<body>
<div class="container-fluid"><div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <h4 class="fw-bold mb-4"><i class="fa fa-edit me-2"></i>Update Profile</h4>

    <% if (successMsg != null) { %>
        <div class="alert alert-success rounded-3"><i class="fa fa-check-circle me-2"></i><%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-danger rounded-3"><i class="fa fa-exclamation-circle me-2"></i><%= errorMsg %></div>
    <% } %>

    <div class="card shadow-sm border-0 rounded-4 p-4" style="max-width:700px">
        <form id="profileForm" action="<%= request.getContextPath() %>/UpdateMentorServlet"
              method="post" enctype="multipart/form-data" novalidate>

            <!-- Full Name -->
            <div class="mb-3">
                <label class="form-label fw-semibold">Full Name</label>
                <input type="text" name="name" class="form-control rounded-3"
                       value="<%= existName %>" required>
                <div class="invalid-feedback">Full name is required.</div>
            </div>

            <!-- ✅ Phone — now required with 10-digit validation -->
            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <i class="fa fa-phone me-1 text-success"></i>Phone Number
                    <span class="text-danger fw-bold">*</span>
                    <small class="text-muted ms-1">(shared with user via email after booking)</small>
                </label>
                <div class="input-group">
                    <span class="input-group-text bg-white">
                        <i class="fa fa-phone text-success"></i>
                    </span>
                    <input type="tel"
                           id="phoneInput"
                           name="phone"
                           class="form-control rounded-end-3"
                           placeholder="e.g. 9876543210"
                           value="<%= existPhone %>"
                           maxlength="10"
                           required>
                </div>
                <!-- live feedback message shown by JS -->
                <div id="phoneFeedback" class="form-text text-danger d-none">
                    <i class="fa fa-exclamation-circle me-1"></i>
                    Phone number is required — users contact you via this number after booking.
                </div>
                <div id="phoneValid" class="form-text text-success d-none">
                    <i class="fa fa-check-circle me-1"></i>Looks good!
                </div>
            </div>

            <!-- Bio -->
            <div class="mb-3">
                <label class="form-label fw-semibold">Bio</label>
                <textarea name="bio" class="form-control rounded-3" rows="4"
                          placeholder="Tell users about yourself..."><%= existBio %></textarea>
            </div>

            <!-- Specialization -->
            <div class="mb-3">
                <label class="form-label fw-semibold">Specialization (select all that apply)</label>
                <div class="row g-2">
                    <% String[] specs = {"Web","Java","C++","Python","Data Science","Machine Learning","UI/UX","Cloud","Android"};
                       for (String sp : specs) {
                           boolean checked = existSpec.toLowerCase().contains(sp.toLowerCase()); %>
                    <div class="col-auto">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialization"
                                   id="sp_<%= sp %>" value="<%= sp %>" <%= checked ? "checked" : "" %>>
                            <label class="form-check-label" for="sp_<%= sp %>"><%= sp %></label>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Profile Photo -->
            <div class="mb-4">
                <label class="form-label fw-semibold">Profile Photo</label>
                <input type="file" name="photo" class="form-control rounded-3" accept="image/*">
            </div>

            <button type="submit" class="btn btn-success px-4 rounded-3">
                <i class="fa fa-save me-2"></i>Save Changes
            </button>

        </form>
    </div>

</div></div></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
const phoneInput    = document.getElementById('phoneInput');
const phoneFeedback = document.getElementById('phoneFeedback');
const phoneValid    = document.getElementById('phoneValid');

// ── Live validation while typing ─────────────────────────────────────────────
phoneInput.addEventListener('input', function () {
    // Only allow digits
    this.value = this.value.replace(/\D/g, '');
    validatePhone();
});

phoneInput.addEventListener('blur', validatePhone);

function validatePhone() {
    const val = phoneInput.value.trim();
    const valid = /^\d{10}$/.test(val);

    if (val === '') {
        // Empty — show required message
        phoneInput.classList.add('is-invalid');
        phoneInput.classList.remove('is-valid');
        phoneFeedback.textContent = '⚠️ Phone number is required — users contact you via this after booking.';
        phoneFeedback.classList.remove('d-none');
        phoneValid.classList.add('d-none');
    } else if (!valid) {
        // Has value but not 10 digits
        phoneInput.classList.add('is-invalid');
        phoneInput.classList.remove('is-valid');
        phoneFeedback.textContent = '⚠️ Enter a valid 10-digit phone number.';
        phoneFeedback.classList.remove('d-none');
        phoneValid.classList.add('d-none');
    } else {
        // Valid
        phoneInput.classList.remove('is-invalid');
        phoneInput.classList.add('is-valid');
        phoneFeedback.classList.add('d-none');
        phoneValid.classList.remove('d-none');
    }
}

// ── Block form submit if phone invalid ───────────────────────────────────────
document.getElementById('profileForm').addEventListener('submit', function (e) {
    const val   = phoneInput.value.trim();
    const valid = /^\d{10}$/.test(val);

    if (!valid) {
        e.preventDefault();
        e.stopPropagation();

        // Highlight the field
        phoneInput.classList.add('is-invalid');
        phoneFeedback.classList.remove('d-none');
        phoneValid.classList.add('d-none');

        // SweetAlert popup
        Swal.fire({
            icon: 'warning',
            title: 'Phone Number Required!',
            html: 'Please enter your <strong>10-digit phone number</strong>.<br>' +
                  '<small class="text-muted">Users will contact you on this number after their booking is approved.</small>',
            confirmButtonColor: '#198754',
            confirmButtonText: 'Enter Phone Number'
        }).then(() => {
            phoneInput.focus();
        });
    }
});

// ── Trigger validation on page load if phone already filled ──────────────────
if (phoneInput.value.trim() !== '') {
    validatePhone();
}
</script>
</body>
</html>
