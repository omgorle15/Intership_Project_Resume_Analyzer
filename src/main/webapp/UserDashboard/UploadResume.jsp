<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page session="true" %>
<%@ include file="layout.jsp" %>

<%
// ✅ Session guard
if (session.getAttribute("userName") == null) {
    response.sendRedirect("../SignIn.jsp");
    return;
}

// ✅ Success message
String msg = (String) session.getAttribute("successMessage");
if (msg != null) session.removeAttribute("successMessage");

// ✅ Error message from servlet (invalid type, too large, read error)
String uploadError = (String) session.getAttribute("uploadError");
if (uploadError != null) session.removeAttribute("uploadError");
%>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
body         { background: #f4f6f9; }
.upload-card { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
.upload-area { border: 2px dashed #198754; border-radius: 15px; padding: 40px; text-align: center; cursor: pointer; transition: 0.3s; }
.upload-area:hover { background: #f8f9fa; transform: scale(1.02); }
.btn-upload  { background: #198754; color: white; border-radius: 25px; padding: 10px 30px; }
.btn-upload:hover { background: #157347; color: white; }
.file-badge  { display: inline-block; background: #e8f5e9; color: #198754; border-radius: 20px; padding: 6px 16px; font-size: 0.88rem; margin-top: 10px; }
.format-badge { font-size: 0.75rem; padding: 3px 8px; border-radius: 10px; }
</style>

<div class="container-fluid">
<div class="row">
<div class="col-md-10 p-5">
<div class="upload-card text-center">

    <h3 class="mb-1">📄 Upload Your Resume</h3>
    <p class="text-muted mb-4">We'll analyze it with AI and give you ATS score, career advice, and job suggestions.</p>

    <% if (msg != null) { %>
        <div class="alert alert-success text-center rounded-3"><%= msg %></div>
    <% } %>

    <form action="<%=request.getContextPath()%>/UploadResume"
          method="post"
          enctype="multipart/form-data"
          id="uploadForm">

        <!-- Upload Area -->
        <label for="resumeFile" class="upload-area w-100 d-block">
            <div id="dropIcon">
                <i class="bi bi-cloud-arrow-up" style="font-size:2.5rem;color:#198754;"></i>
                <h5 class="mt-2">Click to Upload Resume</h5>
            </div>

            <!-- ✅ Accepted formats badge -->
            <div class="mt-2">
                <span class="badge bg-success format-badge me-1">PDF</span>
                <span class="badge bg-primary format-badge me-1">DOCX</span>
                <span class="badge bg-secondary format-badge">DOC</span>
            </div>
            <p class="text-muted mt-1" style="font-size:0.82rem;">Max 5 MB</p>

            <input type="file"
                   name="resumeFile"
                   id="resumeFile"
                   class="form-control d-none"
                   accept=".pdf,.doc,.docx"
                   onchange="displayFileName(this)"
                   required>
        </label>

        <!-- Selected file name -->
        <div id="fileName" class="mt-3"></div>

        <!-- Query box -->
        <textarea name="userQuery"
          class="form-control mb-3 mt-4"
          rows="4"
          placeholder="Ask anything about your resume (e.g. Give ATS score, suggest improvements, recommend jobs)"></textarea>

        <div class="mt-3">
            <button type="submit" class="btn btn-upload" id="submitBtn">
                <i class="bi bi-cpu me-2"></i>Analyze Resume
            </button>
        </div>

    </form>

</div>
</div>
</div>
</div>

<script>
// ── Show selected file name ────────────────────────────────────────────────────
function displayFileName(input) {
    const file = input.files[0];
    const display = document.getElementById('fileName');

    if (!file) { display.innerHTML = ''; return; }

    const allowed = ['pdf', 'doc', 'docx'];
    const ext     = file.name.split('.').pop().toLowerCase();
    const sizeMB  = (file.size / (1024 * 1024)).toFixed(2);

    // Client-side type check
    if (!allowed.includes(ext)) {
        input.value = '';
        display.innerHTML = '';
        Swal.fire({
            icon: 'error',
            title: 'Invalid File Type!',
            html: 'Only <b>PDF</b>, <b>DOCX</b>, and <b>DOC</b> files are accepted.',
            confirmButtonColor: '#dc3545'
        });
        return;
    }

    // Client-side size check (5 MB)
    if (file.size > 5 * 1024 * 1024) {
        input.value = '';
        display.innerHTML = '';
        Swal.fire({
            icon: 'error',
            title: 'File Too Large!',
            html: 'Maximum allowed size is <b>5 MB</b>. Your file is <b>' + sizeMB + ' MB</b>.',
            confirmButtonColor: '#dc3545'
        });
        return;
    }

    // Show file info
    const iconMap = { pdf: '📄', docx: '📝', doc: '📝' };
    display.innerHTML =
        '<span class="file-badge">' +
        (iconMap[ext] || '📎') + ' ' + file.name +
        ' &nbsp;|&nbsp; ' + sizeMB + ' MB' +
        '</span>';
}

// ── Show loading on submit ────────────────────────────────────────────────────
document.getElementById('uploadForm').addEventListener('submit', function (e) {
    const fileInput = document.getElementById('resumeFile');
    if (!fileInput.files || fileInput.files.length === 0) {
        e.preventDefault();
        Swal.fire({
            icon: 'warning',
            title: 'No File Selected!',
            text: 'Please choose a PDF, DOCX, or DOC file before submitting.',
            confirmButtonColor: '#198754'
        });
        return;
    }

    const btn = document.getElementById('submitBtn');
    btn.disabled    = true;
    btn.innerHTML   = '<span class="spinner-border spinner-border-sm me-2"></span>Analyzing...';

    Swal.fire({
        title: 'Analyzing Your Resume...',
        html: 'AI is reading your resume and generating insights.<br><small class="text-muted">This may take 10–20 seconds.</small>',
        allowOutsideClick: false,
        allowEscapeKey: false,
        didOpen: () => Swal.showLoading()
    });
});

// ✅ Show error SweetAlert if servlet sent back an error
<% if (uploadError != null) { %>
window.addEventListener('DOMContentLoaded', function () {
    Swal.fire({
        icon: 'error',
        title: 'Upload Failed!',
        html: '<%= uploadError.replace("'", "\\'") %>',
        confirmButtonColor: '#dc3545',
        confirmButtonText: 'Try Again'
    });
});
<% } %>
</script>

<%@ include file="layoutFooter.jsp" %>
