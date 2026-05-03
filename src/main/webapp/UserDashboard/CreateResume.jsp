<%@ include file="layout.jsp" %>

<style>

.form-container {
    max-width: 1100px;
    margin: 40px auto;
}

.card-custom {
    background: #ffffff;
    border: none;
    border-radius: 20px;
    box-shadow: 0 15px 40px rgba(0, 0, 0, 0.08);
}

.section-title {
    font-weight: 600;
    font-size: 18px;
    color: #198754;
    margin-top: 25px;
    margin-bottom: 15px;
    position: relative;
}

.section-title::after {
    content: "";
    width: 50px;
    height: 3px;
    background: #198754;
    position: absolute;
    left: 0;
    bottom: -6px;
    border-radius: 10px;
}

.form-control, .form-select {
    border-radius: 12px;
    padding: 10px 15px;
}

.education-block {
    background: #f9fbfd;
    border: 1px solid #e3e8ee;
    border-radius: 15px;
}

.btn-custom {
    border-radius: 30px;
    padding: 10px 35px;
    font-weight: 500;
}

</style>

<div class="form-container">
<div class="card shadow-lg card-custom p-4">

<h3 class="text-center fw-bold mb-4">Professional Resume Builder</h3>

<form action="saveResume.jsp" method="post">

<!-- ================= Personal Info ================= -->
<div class="section-title">Personal Information</div>

<div class="row">
    <div class="col-md-6 mb-3">
        <input type="text" name="name" class="form-control" placeholder="Full Name" required>
    </div>
    <div class="col-md-6 mb-3">
        <input type="email" name="email" class="form-control" placeholder="Email" required>
    </div>
    <div class="col-md-6 mb-3">
        <input type="text" name="phone" class="form-control" placeholder="Phone" required>
    </div>
    <div class="col-md-6 mb-3">
        <input type="text" name="address" class="form-control" placeholder="Location">
    </div>
    <div class="col-md-12 mb-3">
        <input type="text" name="linkedin" class="form-control" placeholder="LinkedIn URL">
    </div>
</div>

<!-- ================= Summary ================= -->
<div class="section-title">Professional Summary</div>
<textarea name="objective" class="form-control mb-3" rows="3" required></textarea>

<!-- ================= Education ================= -->
<div class="section-title">Education</div>

<div id="educationSection">
    <div class="education-block p-3 mb-3">
        <div class="row">
            <div class="col-md-6 mb-2">
                <input type="text" name="degree" class="form-control" placeholder="Degree" required>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="college" class="form-control" placeholder="College" required>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="year" class="form-control" placeholder="Year">
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="cgpa" class="form-control" placeholder="CGPA / Percentage">
            </div>
        </div>
    </div>
</div>

<button type="button" class="btn btn-outline-success btn-sm mb-3"
        onclick="addEducation()">+ Add More Education</button>


<!-- ================= Experience & Skills ================= -->
<div class="row">

    <!-- Experience -->
    <div class="col-md-6">
        <div class="section-title">Experience</div>

        <select name="experienceType" id="experienceType"
                class="form-select mb-3"
                onchange="toggleExperienceFields()" required>
            <option value="">-- Select --</option>
            <option value="Fresher">Fresher</option>
            <option value="Experienced">Experienced</option>
        </select>

        <div id="experienceFields" style="display:none;">
            <input type="text" name="company" class="form-control mb-2" placeholder="Company Name">
            <input type="text" name="jobRole" class="form-control mb-2" placeholder="Job Role">
            <input type="text" name="duration" class="form-control mb-2" placeholder="Duration">
            <textarea name="jobDescription" class="form-control mb-3"
                      rows="3" placeholder="Job Description"></textarea>
        </div>
    </div>

    <!-- Skills -->
    <div class="col-md-6">
        <div class="section-title">Skills</div>
        <input type="text" name="skills" class="form-control mb-3"
               placeholder="Java, Spring Boot, MySQL">
    </div>

</div>

<!-- ================= Projects & Certifications ================= -->
<div class="row mt-3">

    <div class="col-md-6">
        <div class="section-title">Projects</div>
        <textarea name="projects" class="form-control mb-3" rows="4"></textarea>
    </div>

    <div class="col-md-6">
        <div class="section-title">Certifications</div>
        <textarea name="certifications" class="form-control mb-3" rows="4"></textarea>
    </div>

</div>

<!-- ================= Submit Button ================= -->
<div class="text-center mt-4">
    <button type="submit" class="btn btn-success btn-custom shadow">
        Generate Resume
    </button>
</div>

</form>
</div>
</div>


<script>
function toggleExperienceFields(){
    let type = document.getElementById("experienceType").value;
    let fields = document.getElementById("experienceFields");
    fields.style.display = (type === "Experienced") ? "block" : "none";
}

function addEducation(){
    let container = document.getElementById("educationSection");

    let block = document.createElement("div");
    block.classList.add("education-block","p-3","mb-3");

    block.innerHTML = `
        <div class="row">
            <div class="col-md-6 mb-2">
                <input type="text" name="degree" class="form-control" placeholder="Degree" required>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="college" class="form-control" placeholder="College" required>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="year" class="form-control" placeholder="Year">
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="cgpa" class="form-control" placeholder="CGPA / Percentage">
            </div>
            <div class="col-md-12 text-end">
                <button type="button" class="btn btn-danger btn-sm"
                        onclick="this.closest('.education-block').remove()">
                    Remove
                </button>
            </div>
        </div>
    `;

    container.appendChild(block);
}
</script>

<%@ include file="layoutFooter.jsp" %>